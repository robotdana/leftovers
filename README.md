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

see the [built in config files](https://github.com/robotdana/leftovers/tree/master/lib/config) for examples.
see the [complete config documentation](https://github.com/robotdana/leftovers/tree/master/Configuration.md) for details.

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
  - [`calls:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#calls:), [`defines:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#defines:), [`defines_group:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#defines_group:)
    - **source** _at least one is required_
    - [`arguments:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#arguments:)
    - [`keys:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#keys:)
    - [`itself:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#itself:)
    - **transformation** _optional_
    - [`add_prefix:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#add_prefix:)
      - [`from_argument:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#from_argument:)
      - [`joiner:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#joiner:)
    - [`add_suffix:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#add_suffix:)
      - `from_argument:`
      - `joiner:`
    - [`delete_suffix:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#delete_suffix:)
    - [`delete_prefix:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#delete_prefix:)
    - [`delete_before:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#delete_before:)
    - [`delete_after:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#delete_after:)
    - [`replace_with:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#replace_with:)
    - [`activesupport:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#activesupport:)
    **condition** _optional_
    - [`has_argument:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_argument:)
      - `has_prefix:`
      - `has_suffix:`
      - `matches:`
      - [`key`:]
      - [`value:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_argument:)
        - [`type:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#has_argument:)
    - [`unless:`](https://github.com/robotdana/leftovers/tree/master/Configuration.md#unless:)
      - **conditions** _at least one is required_
      - `has_argument:`
        - `has_prefix:`
        - `has_suffix:`
        - `matches:`
        - `with_value:`

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
