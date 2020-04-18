# Leftovers
[![travis](https://travis-ci.org/robotdana/leftovers.svg?branch=master)](https://travis-ci.org/robotdana/leftovers)

Find unused methods, Classes, CONSTANTS, @instance_variables, @@class_variables, and $global_variables in your ruby projects

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

see the [complete config documentation](https://github.com/robotdana/leftovers/tree/master/Configuration.md) for details.
see the [built in config files](https://github.com/robotdana/leftovers/tree/master/lib/config) for examples.

- [`include_paths:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#include_paths:) _optional_
- [`exclude_paths:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#exclude_paths:) _optional_
- [`test_paths:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#test_paths:) _optional_
- [`gems:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#gems:) _optional_
- [`rules:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#rules:) _optional_
  - [`names:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#names:) _required_
    - [`has_prefix](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_prefix:) _optional_
    - [`has_suffix](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_suffix:) _optional_
    - [`matches](https://github.com/robotdana/leftovers/tree/master/Configuration.md#matches:) _optional_
  - [`paths:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#paths:) _optional_
  - **action** _at least one is required_
  - [`skip:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#skip:)
  - [`calls:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#calls:), [`defines:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#defines:)
    - [`arguments:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#arguments:), [`keys:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#keys:), [`itself:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#itself:) _at least one is required_
    - [`transforms:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#transforms), [`linked_transforms:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#linked_transforms) _optional_
        - `original:`, `add_prefix:`, `add_suffix:`, `delete_prefix:`, `delete_suffix:`, `replace_with:`
        - `delete_before:`, `delete_after:`, `downcase:`, `upcase:`, `capitalize:`, `swapcase:`
        - `pluralize`, `singularize`, `camelize`, `underscore`, `demodulize`, `deconstantize` _requires activesupport_
    - [`if:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#if:), [`unless:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#unless:)
      - [`has_argument:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_argument:)
        - [`keyword`:]
          - `has_prefix:`
          - `has_suffix:`
          - `matches:`
        - [`value:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_argument:)
          - [`type:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_argument:)

## Limitations

- Leftovers will report methods/constants you define that are called outside your code (perhaps by gems) as unused

  Add these names to the `rules:` list with `skip: true` in the `.leftovers.yml` or add an inline comment with `# leftovers:allow my_method_name`
- Leftovers doesn't execute your code so isn't aware of dynamic calls to `send` (e.g. `send(variable_method_name)`). (it is aware of static calls (e.g. `send(:my_method_name)`), so using send to bypass method privacy is "fine")

  Add the method/pattern to the `rules:` list with `skip: true` in the `.leftovers.yml`, or add an inline comment with the list of possibilities `# leftovers:call my_method_1, my_method_2`.
- Leftovers compares by name only, so multiple methods with the same name will count as used even if only one is.
- haml & erb line and column numbers will be wrong as the files have to be precompiled before checking.

## Other tools

- [rubocop](https://github.com/rubocop-hq/rubocop) has a cop that will alert for unused local variables and method arguments, and a cop that will report unreachable code.
- [coverband](https://github.com/danmayer/coverband) will report which methods are _actually_ called by your _actual_ production code

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robotdana/leftovers.

I especially encourage issues and improvements to the default config, whether expanding the existing config/*.yml (rails.yml is particularly incomplete) or adding new gems.
The file should be named `[rubygems name].yml` and its structure is identical to the [project config](#configuration)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
