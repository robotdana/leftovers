# Leftovers
[![travis](https://travis-ci.com/robotdana/leftovers.svg?branch=main)](https://travis-ci.com/robotdana/leftovers)
[![Gem Version](https://badge.fury.io/rb/leftovers.svg)](https://rubygems.org/gems/leftovers)

Find unused `methods`, `Classes`, `CONSTANTS`, `@instance_variables`, `@@class_variables`, and `$global_variables` in your ruby projects.

## Why?

Code that never gets executed is code that you shouldn't need to maintain

- Leftovers from refactoring
- Partially removed features
- Typos and THIS NEVER WOULD HAVE WORKED code
- Code that you only keep around because there are tests of it

Leftovers will use static analysis to find these bits of code for you.

It's aware of how some gems call methods for you, including (still somewhat incomplete) support for rails.

## Features

- Fully configurable handling of methods that call other methods with literal arguments, and constant assignment
- magic comments
- designed to be run as a CI step
- optimised for speed
- built in config for some gems. (please make PRs with more gems)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'leftovers', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install leftovers

## Usage

Run `leftovers` in your command line in the root of your project.
This will output progress as it collects the calls/references and definitions in your project.
Then it will output any defined methods (or classes etc) which are not called.

```
$ leftovers
checked 25 files, collected 2473 calls, 262 definitions
Only directly called in tests:
lib/hello_world.rb:10:6 tested_unused_method def tested_unused_method
lib/hello_world.rb:18:6 another_tested_unused_method def another_tested_unused_method
Not directly called at all:
lib/hello_world.rb:6:6 generated_method= attr_accessor :generated_method
lib/hello_world.rb:6:6 generated_method attr_accessor :generated_method

how to resolve: https://github.com/robotdana/leftovers/tree/main/Readme.md#how-to-resolve
```

if there is an overwhelming number of results, try using [`--write-todo`](#write-todo)

## How to resolve

When running `leftovers` you'll be given a list of method, constant, and variable definitions it thinks are unused. Now what?

they were unintentionally left when removing their calls:
  - remove their definitions. (they're still there in your git etc history if you want them back)

they are called dynamically:
  - define how they're called dynamically in the [.leftovers.yml](#configuration-file); or
  - mark the calls with [`# leftovers:call my_unused_method`](#leftovers-call); or
  - mark the definition with [`# leftovers:keep`](#leftovers-keep)

they're defined intentionally to only be used by tests:
  - add [`# leftovers:test_only`](#leftovers-test-only)

they're from a file that shouldn't be checked by leftovers:
  - add the paths to the [`exclude_paths:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#exclude_paths) list in the [.leftovers.yml](#configuration-file) file

if there are too many to address when first adding leftovers to your project, try running [`leftovers --write-todo`](#write-todo),

### --write-todo

running `leftovers --write-todo` will generate a supplemental configuration file allowing all the currently detected uncalled definitions, which will be read on subsequent runs of `leftovers` without alerting any of the items mentioned in it.

commit this file so you/your team can gradually address these items while still having leftovers alert you to any newly unused items.

## Magic comments

### `# leftovers:keep`
_aliases `leftovers:keeps`, `leftovers:skip`, `leftovers:skips`, `leftovers:skipped`, `leftovers:allow`, `leftovers:allows`, `leftovers:allowed`_
To mark a method definition as not unused, add the comment `# leftovers:keep` on the same line as the definition

```ruby
class MyClass
  def my_method # leftovers:keep
    true
  end
end
```
This would report `MyClass` is unused, but not my_method
To do this for all definitions of this name, instead of adding a comment, add the name to the [`keep:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#keep) list in the [configuration file](#configuration-file).

### `# leftovers:test_only`
_aliases `leftovers:for_test`, `leftovers:for_tests`, `leftovers:test`, `leftovers:tests`, `leftovers:testing`_

To mark a definition from a non-test dir, as intentionally only used by tests, use `leftovers:test_only`
```ruby
# app/my_class.rb
class MyClass
  def my_method # leftovers:test_only
    true
  end
end
```
```ruby
# spec/my_class_spec.rb
describe MyClass do
  it { expect(subject.my_method).to be true }
end
```

This would consider `my_method` to be used, even though it is only called by tests.

To do this for all definitions of this name, instead of adding a comment, add the name to the [`test_only:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#test_only) list in the [configuration file](#configuration-file).

### `# leftovers:call`
_aliases `leftovers:calls`_
To mark a dynamic call that doesn't use literal values, use `leftovers:call` with the method name listed
```ruby
method = [:puts, :warn].sample # leftovers:call puts, warn
send(method, 'text')
```

This would consider `puts` and `warn` to both have been called

## Configuration file

The configuration is read from `.leftovers.yml` in your project root.
Its presence is optional and all of these settings are optional.

- [`include_paths:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#include_paths)
- [`exclude_paths:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#exclude_paths)
- [`test_paths:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#test_paths)
- [`requires:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#requires)
- [`gems:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#gems)
- [`keep:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#keep)
- [`test_only:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#test_only)
- [`dynamic:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#dynamic)

see the [complete config documentation](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md) for details.
see the [built in config files](https://github.com/robotdana/leftovers/tree/main/lib/config) or [this repo's own config](https://github.com/robotdana/leftovers/tree/main/.leftovers.yml) for examples.

## Limitations

- Leftovers will report methods/constants you define that are called outside your code (perhaps by gems) as unused

  Add these names to the `keep:` list in the `.leftovers.yml` or add an inline comment with `# leftovers:allow my_method_name`
- Leftovers doesn't execute your code so isn't aware of e.g. variables in calls to `send` (e.g. `send(variable_method_name)`). (it is aware of static calls (e.g. `send(:my_method_name)`), so using send to bypass method privacy is "fine")

  Add the method/pattern to the `dynamic:` list with `skip: true` in the `.leftovers.yml`, or add an inline comment with the list of possibilities `# leftovers:call my_method_1, my_method_2`.
- Leftovers compares by name only, so multiple definitions with the same name will count as used even if only one is.
- haml, slim & erb line and column numbers will be wrong as the files have to be precompiled before checking.

## Other tools

- [rubocop](https://github.com/rubocop-hq/rubocop) has a cop that will alert for unused local variables and method arguments, and a cop that will report unreachable code.
- [coverband](https://github.com/danmayer/coverband) will report which methods are _actually_ called by your _actual_ production code

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robotdana/leftovers.

I especially encourage issues and improvements to the default config, whether expanding the existing config/*.yml (rails.yml is particularly incomplete) or adding new gems.
The file should be named `[rubygems name].yml` and its structure is identical to the [project config](#configuration)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
