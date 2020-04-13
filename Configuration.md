| `add_suffix:` | Adds a suffix | `add_suffix: '='`, `add_suffix: _attributes` |
| `add_prefix:` | Adds a prefix | `add_prefix: be_`, `add_prefix: '@'` |
| `delete_suffix:` | Removes a suffix if it's there | `delete_suffix: _html` |
| `delete_prefix:` | Removes a prefix if it's there | `delete_prefix: have_, add_prefix: has_` |
| `delete_after:` | keep only the text before this string (e.g. for splitting "controller#action") | `delete_after: '#'` |
| `delete_before:` | keep only the text after this string | `delete_before: '#"` |
| `replace_with:` | replace the string with whole different string | `replace_with: html` |
| `activesupport:` | A list of rails' activesupport transformations. requires the activesupport gem | `activesupport: [singularize, camelize]` |


### `include_paths:`

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

### `exclude_paths:`

List filenames/paths that match the above that you might want to exclude, using the gitignore format.
By default it will also read your project's .gitignore file and ignore anything there.

```yml
exclude_paths:
  - /some/long/irrelevant/generated/file
```

### `test_paths:`

list filenames/paths of test directories that will be used to determine if a method/etc is only tested but not otherwise used.
Also in the gitignore format

```yml
test_paths:
  - /test/
  - /spec/
```

### `rules:`

This is the most complex part of configuration, and is a list of methods that define/call other methods/classes/etc.
Each must have a `name:` or list of `names:`. and can optionally be limited to a `path:` or list of `paths:`.

This rule can either `skip:` these names, or describe method/class `calls:` and definitions (`defines:`).

#### `name:`, `names:`

**required**

list methods/classnames/etc that this rule applies to.
This list can be exact matches or partial matches with `has_prefix:` and/or `has_suffix:` or regex pattern (`matches:`).

```yml
rules:
  - name:
      - initialize
      - ConstantName
      - has_suffix: Helper # will match Helper, LinkHelper FormHelper, etc
      - has_prefix: be_ # will match be_equal, be_invalid, etc
      - { has_prefix: is_, has_suffix: '?' } # will match is_invalid?, is_equal? etc
      - matches: '(?-mix:column_\d+)' # will match column_1, column_2, column_99, etc
    skip: true
```

#### `path:`, `paths:`

An optional list of paths that limits what paths this method rule can apply to, defined using a .gitignore-esque format

```yml
rules:
  - name:
      - has_suffix: Helper
    path: /app/helpers
    skip: true
```

#### `skip:`

Skip methods that are called on your behalf by code outside your project, or called dynamically using send with variables.

You can also skip method calls and definitions in place using [magic comments](#magic_comments).

```yml
rules:
  - name: initialize
    skip: true
```
```ruby
def initialize
end
```

will not report that you didn't directly use the initialize method

#### `calls:`, `defines:`

Describe implicitly called and defined methods using these keys. they're structured the same way:

It must have at least one of `position:`, `keyword:`, or `keys: '*'` which points to the implied method definition/call.
This value must be a literal string, symbol, or array of strings or symbols.

#### `argument:`, `arguments:`

the position or keyword of the value being implicitly called/defined.
This value must be itself a literal String, Symbol, or Array or Hash whose values are Strings and Symbols or more nested Arrays and Hashes.
Variables and other method calls returning values will be ignored.

`*` means all positional arguments values. `**` means all keyword arguments values.
Positional arguments start at 1.

##### Example

```yml
rules:
  # `send(:my_method, arg)` is equivalent to `my_method(arg)`
  - name: send
    calls:
      argument: 1
```
```ruby
  user.send(:my_private_method, true)
```
will count as a call to `my_private_method`.

```yml
  - name: attr_reader
    defines:
      arguments: '*'
```
```ruby
attr_reader :my_attr, :my_other_attr
```
will count as a definition of `my_attr` and `my_other_attr` and will need to be used elsewhere or they'll be reported as leftovers.

```yml
rules:
  - name: validate
  calls:
    - arguments: ['*', if, unless]
```
```ruby
validate :does_not_match_existing_record, if: :new_record?
```
will count as a call to `does_not_match_existing_record`, and `new_record?`

#### `keys: '*'`

When the keyword argument **keywords** are the thing being called.

##### Example

```yml
rules:
  - name: validates
      calls:
        - arguments: '*'
        - keys: '*'
          add_suffix: Validator
          activesupport: camelize
```
```ruby
validates :first_name, :surname, presence: true
```
will count calls for `validates`, `first_name`, `surname`, and `PresenceValidator`

#### `transforms:`

Sometimes the method being called is modified from the literal argument, sometimes that's just appending an `=` and sometimes it's more complex:

Transforms can be grouped together, any one of these calls would count as a call for any other. e.g
```yml
- name: attribute
    defines:
      - argument: 1
        transforms:
          - true # no transformation
          - add_suffix: '?'
          - add_suffix: '='
```

If these transforms shouldn't be grouped together, then they can be listed separately for different (or the same) arguments.
e.g. attr_accessor, which can be replaced with attr_reader/writer if only one is used.
```yml
- name: attr_accessor
  defines:
    - argument: '*'
      add_suffix: '='
    - argument: '*'
```

| transform | effect | examples |
| --- | --- | --- |

`add_prefix:` has some additional options, rather than just being a literal string it could be a further set of keywords,
for example delegate in the next section:

#### `if:` and `unless:`

Sometimes what to do depends on other arguments than the ones looked at:
e.g. rails' `delegate` method has a `prefix:` argument of its own that is used when defining methods:

`if:` and `unless:` work the same way, and are currently limited to looking at keyword arguments and their values.
```yml
rules:
  - name: delegate
    defines:
      - argument: '*'
        if:
          has_argument:
            keyword: prefix
            value: true # if the value of the prefix keyword argument is literal true value
        add_prefix:
          from_argument: to # use the value of the "to" keyword as the prefix
          joiner: '_' # joining with _ to the original string
      - argument: '*'
        if: # if the method call has a prefix keyword argument that is not a literal true value
          has_argument:
            keyword: prefix
            value:
              type: [String, Symbol]
        add_prefix:
          from_argument: prefix # use the value of the "prefix" keyword as the prefix
          joiner: '_' # joining with _ to the original string
    calls:
      - argument: to # consider the to argument called.
      - argument: '*'
        if:
          has_argument: prefix # if there is a prefix, consider the original method called.
```

### `gems:`

list the gems your project uses whose default config you want to load.

See [the built in config files](https://github.com/robotdana/leftovers/tree/master/lib/config) for which gem config is available. Please submit a PR or issues at the [Leftovers github project](https://github.com/robotdana/leftovers) if your favorite gem is missing

(ruby.yml will always be loaded.)
```yml
gems:
  - rails
  - rspec
```
