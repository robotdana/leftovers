# Leftovers

Find unused methods, Classes, CONSTANTS, @instance_variables, @@class_variables, and $global_variables in your ruby projects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'leftovers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install leftovers

## Usage

Run `leftovers` in your terminal in the root of your project.
This will output progress as it collects the calls/references and definitions in your project.
Then it will output any defined methods (or classes etc) which are not called.

file path : line number : column number, the method/etc name, the line of code that defined the method.
```
$ leftovers
checked 25 files, collected 2473 calls, 262 definitions
Only directly called in tests:
lib/hello_world.rb:10:6 tested_unused_method def tested_unused_method
lib/hello_world.rb:18:6 another_tested_unused_method def another_tested_unused_method
Not directly called at all:
lib/hello_world.rb:6:6 generated_method= attr_accessor :generated_method
lib/hello_world.rb:6:6 generated_method attr_accessor :generated_method
```

## Configuration

The configuration is read from `.leftovers.yml` in your project root.
Its presence is optional and all of these settings are optional:

see [the built in config files](https://github.com/robotdana/leftovers/tree/master/lib/config) for examples.

### `includes:`

List filenames/paths in the gitignore format of files to be checked using a [gitignore-esque format](https://github.com/robotdana/fast_ignore#using-an-includes-list).

By default it checks the following:
```yml
include_paths:
  - '*.rb'
  - '*.rake'
  - '*.ru'
  - Rakefile
  - Gemfile
  - Capfile
  - '*.haml'
  - '*.erb'
  - '*.builder'
  - '*.jbuilder'
  - '*.gemspec'
```

Also it will check files with no extension that have `ruby` in the shebang/hashbang, e.g. `#!/usr/bin/env ruby` or `#!/usr/bin/ruby` etc

### `excludes:`

List filenames/paths that match the above that you might want to exclude, using the gitignore format.
By default it will also read your project's .gitignore file and ignore anything there.

```yml
excludes:
  - /some/long/irrelevant/generated/file
```

### `tests:`

list filenames/paths of test directories that will be used to determine if a method/etc is only tested but not otherwise used.
Also in the gitignore format

```yml
tests:
  - /test/
  - /spec/
```

### `allowed:`

list methods/classnames/etc that are considered unused by Leftovers
but that you want to be allowed

filtering is by exact match or `prefix:` and/or `suffix:` or regex pattern (`match:`).

```yml
allowed:
  - method_name
  - ConstantName
  - suffix: Helper # will match Helper, LinkHelper FormHelper, etc
  - prefix: be_ # will match be_equal, be_invalid, etc
  - prefix: is_
    suffx: ? # will match is_invalid?, is_equal? etc
  - match: '(?-mix:column_\d+)' # will match column_1, column_2, column_99, etc
```

### `rules:`

This is the most complex part of configuration, and is a list of methods that define/call other methods/classes/etc.
each must have a `method:` list (which can use the same prefix/suffix/match matching that the allowed list does above),
a `caller:` list and/or `definer:` list, and optionally a `path:` list that limits what paths this method rule can apply to.

any of the `method:`, `caller:`, `definer:`, and `path:` lists can be single values instead of lists if there's only one.
e.g.

```yml
rules:
  - method:
      - send
      - public_send
    caller:
      position: 1
```

This describes how to handle `send()` and `public_send()`. it considers the first positional argument to be a called method.


the `caller:` and `definer:` list objects are structured the same way, but have many keywords:

It must have at least one of `position:`, `keyword:`, or `key: true` which points to the implied method definition/call.
This value must be a literal string, symbol, or array of strings or symbols.

#### `position:`

the positional argument that is the method/class name being called/defined.
`*` means all positional arguments

e.g
```yml
rules:
  # `send(:my_method, arg)` is equivalent to `my_method(arg)`
  - method: send
    caller:
      position: 1
  # `attr_reader :my_attr` is equivalent to `def my_attr; @my_attr; end`
  - method: attr_reader
    definer:
      position: '*'
```
#### `keyword:`

the keyword argument value that is the method/class name being called/defined.
`*` means all values of keyword arguments
```yml
rules:
  - method: validate
  caller:
    - position: '*'
    - keyword: [if, unless]
```

#### `key: true`

the keyword argument **keywords** are the method/class_name being called/defined.
```yml
rules:
  - method: permit
      caller:
        position: '*'
        keyword: '*'
        key: true
```
(this example, incidentally, is how you get all the positional arguments and nested hashes and arrays that rails likes to use)

#### `transforms:`

Sometimes the method being called is modified from the literal argument, sometimes that's just appending an `=` and sometimes it's more complex:

Transforms can be grouped together, any one of these calls would count as a call for any other. e.g
```yml
- method: attribute
    definer:
      - position: 1
        transforms:
          - true # no transformation
          - suffix: '?'
          - suffix: '='
```

If these transforms shouldn't be grouped together, then they can be listed separately for different (or the same) arguments.
e.g. attr_accessor, which can be replaced with attr_reader/writer if only one is used.
```yml
- method: attr_accessor
  definer:
    - position: '*'
      suffix: '='
    - position: '*'
```

| transform | effect | examples |
| --- | --- | --- |
| `suffix:` | Adds a suffix | `suffix: '='`, `suffix: _attributes` |
| `prefix:` | Adds a prefix | `prefix: be_`, `prefix: '@'` |
| `delete_suffix:` | Removes a suffix if it's there | `delete_suffix: _html` |
| `delete_prefix:` | Removes a prefix if it's there | `delete_prefix: have_, prefix: has_` |
| `before:` | keep only the text before this string (e.g. for splitting "controller#action") | `before: '#'` |
| `after:` | keep only the text after this string | `after: '#"` |
| `replace_with:` | replace the string with whole different string | `replace_with: html` |
| `activesupport:` | A list of rails' activesupport transformations. requires the activesupport gem | `activesupport: [singularize, camelize]` |

`prefix:` has some additional options, rather than just being a literal string it could be a further set of keywords,
for example delegate in the next section:

#### `if:` and `unless:`

Sometimes what to do depends on other arguments than the ones looked at:
e.g. rails' `delegate` method has a `prefix:` argument of its own that is used when defining methods:

`if:` and `unless:` work the same way, and are currently limited to looking at keyword arguments and their values.
```yml
rules:
  - method: delegate
    definer:
      - position: '*'
        if:
          keyword:
            prefix: true # if the value of the prefix keyword argument is literal true value
        prefix:
          from_keyword: to # use the value of the "to" keyword as the prefix
          joiner: '_' # joining with _ to the original string
      - position: '*'
        if: # if the method call has a prefix keyword argument that is not a literal true value
          keyword: prefix
        unless:
          keyword:
            prefix: true
        prefix:
          from_keyword: prefix # use the value of the "prefix" keyword as the prefix
          joiner: '_' # joining with _ to the original string
    caller:
      - keyword: to # consider the to argument called.
      - position: '*'
        if:
          keyword: prefix # if there is a prefix, consider the original method called.
```

### `gems:`

list the gems your project uses whose default config you want to load.

See [the built in config files](https://github.com/robotdana/leftovers/tree/master/lib/config) for which gem config is available. Please submit a PR or issues at the [Leftovers github project](https://github.com/robotdana/leftovers) if your favourite gem is missing

(ruby.yml will always be loaded.)
```yml
gems:
  - rails
  - rspec
```


```

## Limitations

- Leftovers will report methods you define that are called outside your code (perhaps by gems) as unused

  Add the method to the `allowed:` list in the `.leftovers.yml` or add an inline comment with `# leftovers:allow my_method_name`
- Leftovers doesn't execute your code so isn't aware of dynamic calls to `send` (e.g. `send(variable_method_name)`). (it is aware of static calls (e.g. `send(:my_method_name)`), so using send to bypass method privacy is "fine")

  Add the method/pattern to the `allowed:` list in the `.leftovers.yml`, or add an inline comment with the list of possibilities `# leftovers:allow my_method_1 my_method_2`.
- Leftovers compares by name, so multiple methods with the same name will count as used even if only one is.
- haml & erb line and column numbers will be somewhat off.

## Other tools

- [rubocop](https://github.com/rubocop-hq/rubocop) has a cop that will alert for unused local variables and method arguments
- [coverband](https://github.com/danmayer/coverband) will report which methods are _actually_ called by your _actual_ production code.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robotdana/leftovers.

I especially encourage issues and improvements to the default config, whether expanding the existing config/*.yml (rails.yml is particularly incomplete) or adding new gems.
The file should be named `[rubygems name].yml` and its structure is identical to the [project config](#configuration)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
