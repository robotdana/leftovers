# Leftovers
[![travis](https://travis-ci.com/robotdana/leftovers.svg?branch=main)](https://travis-ci.com/robotdana/leftovers)
[![Gem Version](https://badge.fury.io/rb/leftovers.svg)](https://rubygems.org/gems/leftovers)

Find unused `methods`, `Classes`, `CONSTANTS`, `@instance_variables`, `@@class_variables`, and `$global_variables` in your ruby projects.

## Why?

Code that never gets executed is code that you shouldn't need to maintain.

- Leftovers from refactoring
- Partially removed features
- Typos and THIS NEVER WOULD HAVE WORKED code
- Code that you only keep around because there are tests of it.

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
```

## Magic comments

### `# leftovers:keep`
To mark a method definition as not unused, add the comment `# leftovers:keep` on the same line as the definition

```ruby
class MyClass
  def my_method # leftovers:keep
    true
  end
end
```
This would report `MyClass` is unused, but not my_method
To do this for all definitions of this name, add the name with `skip: true` in the configuration file.

### `# leftovers:test`

To mark a definition from a non-test dir, as intentionally only used by tests, use `leftovers:test`
```ruby
# app/my_class.rb
class MyClass
  def my_method # leftovers:test
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

### `# leftovers:call`
To mark a dynamic call that doesn't use literal values, use `leftovers:call` with the method name listed
```ruby
method = [:puts, :warn].sample
send(method, 'text') # leftovers:call puts, warn
```

This would consider `puts` and `warn` to both have been called

## Configuration

The configuration is read from `.leftovers.yml` in your project root.
Its presence is optional and all of these settings are optional:

see the [complete config documentation](https://github.com/robotdana/leftovers/tree/main/Configuration.md) for details.
see the [built in config files](https://github.com/robotdana/leftovers/tree/main/lib/config) for examples.

- [`include_paths:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#include_paths)
- [`exclude_paths:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#exclude_paths)
- [`test_paths:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#test_paths)
- [`gems:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#gems)
- [`keep:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#skip)
  - [`names:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#names)
  - [`paths:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#paths)
  - [`has_argument:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#has_argument)
- [`dynamic:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#dynamic)
  - [`names:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#names)
  - [`paths:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#paths)
  - [`has_argument:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#has_argument)

  - [`calls:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#calls-defines), [`defines:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#calls-defines)
    - [`arguments:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#arguments)
    - [`keywords:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#keys-),
    - [`itself:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#itself-true)
    - [`value:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#itself-true)
    - [`transforms:`](https://github.com/robotdana/leftovers/tree/main/Configuration.md#transforms)

## Limitations

- Leftovers will report methods/constants you define that are called outside your code (perhaps by gems) as unused

  Add these names to the `keep:` list in the `.leftovers.yml` or add an inline comment with `# leftovers:allow my_method_name`
- Leftovers doesn't execute your code so isn't aware of e.g. variables in calls to `send` (e.g. `send(variable_method_name)`). (it is aware of static calls (e.g. `send(:my_method_name)`), so using send to bypass method privacy is "fine")

  Add the method/pattern to the `dynamic:` list with `skip: true` in the `.leftovers.yml`, or add an inline comment with the list of possibilities `# leftovers:call my_method_1, my_method_2`.
- Leftovers compares by name only, so multiple methods with the same name will count as used even if only one is.
- haml & erb line and column numbers will be wrong as the files have to be precompiled before checking.

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
