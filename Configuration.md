# Configuration

The configuration is read from `.leftovers.yml` in your project root.
Its presence is optional and all of these settings are optional:

see the [built in config files](https://github.com/robotdana/leftovers/tree/main/lib/config) for examples.

- [`include_paths:`](#include_paths)
- [`exclude_paths:`](#exclude_paths)
- [`test_paths:`](#test_paths)
- [`gems:`](#gems)
- [`dynamic:`](#dynamic)
  - [`names:`](#names)
    - [`has_prefix](#has_prefix-has_suffix)
    - [`has_suffix](#has_prefix-has_suffix)
    - [`matches](#matches)
  - [`paths:`](#paths)
  - [`skip:`](#skip)
  - [`calls:`](#calls-defines), [`defines:`](#calls-defines)
    - [`arguments:`](#arguments), [`keys:`](#keys-), [`itself:`](#itself-true)
    - [`transforms:`](#transforms), [`linked_transforms:`](#linked_transforms)
        - `original:`, `add_prefix:`, `add_suffix:`, `delete_prefix:`, `delete_suffix:`, `replace_with:`
        - `delete_before:`, `delete_after:`, `downcase:`, `upcase:`, `capitalize:`, `swapcase:`
        - `pluralize:`, `singularize:`, `camelize:`, `underscore:`, `demodulize:`, `deconstantize:`
    - [`if:`](#if-unless), [`unless:`](#if-unless)
      - [`has_argument:`](#has_argument)
        - `keyword:`
          - [`has_prefix:`](#has_prefix-has_suffix)
          - [`has_suffix:`](#has_prefix-has_suffix)
          - [`matches:`](#matches)
        - `value:`
          - [`has_prefix:`](#has_prefix-has_suffix)
          - [`has_suffix:`](#has_prefix-has_suffix)
          - [`matches:`](#matches)
          - `type:`


## `include_paths:`

List filenames/paths in the gitignore format of files to be checked using a [gitignore-esque format](https://github.com/robotdana/fast_ignore#using-an-includes-list).

```yml
include_paths:
  - '*.rb'
  - '*.rake'
  - Gemfile
```

Also it will check files with no extension that have `ruby` in the shebang/hashbang, e.g. `#!/usr/bin/env ruby` or `#!/usr/bin/ruby` etc

## `exclude_paths:`

List filenames/paths that match the above that you might want to exclude, using the gitignore format.
By default it will also read your project's .gitignore file and ignore anything there.

```yml
exclude_paths:
  - /some/long/irrelevant/generated/file
```

## `test_paths:`

list filenames/paths of test directories that will be used to determine if a method/etc is only tested but not otherwise used.
Also in the gitignore format

```yml
test_paths:
  - /test/
  - /spec/
```

## `gems:`

By default Leftovers will look at your Gemfile.lock file to find all gem dependencies

If you don't use bundler, or don't have a Gemfile.lock for some reason, you can still take advantage of the built in handling for certain gems
```yml
gems:
  - rspec
  - rails
```

## `dynamic:`

This is the most complex part of configuration, and is a list of methods that define/call other methods/classes/etc.
Each must have a list of `names:`. and can optionally be limited to a list of `paths:`.

This rule can either `skip:` these names, or describe method/class `calls:` and definitions (`defines:`).

### `names:`
**required**

_alias `name:`_

list methods/classnames/etc that this rule applies to.

```yml
dynamic:
  - names:
      - initialize
      - ClassName
    skip: true
  - name: respond_to_missing?
    skip: true
```

#### `has_prefix:`, `has_suffix:`

To match names other than exact strings, you can use has_suffix or has_prefix or both if you're feeling fancy.

```yml
dynamic:
  - names:
      - has_suffix: Helper # will match Helper, LinkHelper FormHelper, etc
      - has_prefix: be_ # will match be_equal, be_invalid, etc
      - { has_prefix: is_, has_suffix: '?' } # will match is_invalid?, is_equal? etc
    skip: true
```


#### `matches:`

if `has_suffix:` and `has_prefix:` isn't enough, you can use `matches:` to supply a regexp.
This string is automatically converted into a ruby regexp and must match the whole method/constant name.
```yml
dynamic:
  - names:
      - matches: 'column_\d+' # will match column_1, column_2, column_99, but not column_left etc
    skip: true
```

### `paths:`
_alias `path:`_

An optional list of paths that limits what paths this method rule can apply to, defined using a .gitignore-esque format

```yml
dynamic:
  - name:
      - has_suffix: Helper
    path: /app/helpers
    skip: true
```

### `skip:`

Skip methods that are called on your behalf by code outside your project, or called dynamically using send with variables.

You can also skip method calls and definitions in place using [magic comments](https://github.com/robotdana/leftovers/tree/main/README.md#magic-comments).

```yml
dynamic:
  - name: initialize
    skip: true
```
```ruby
def initialize
end
```

will not report that you didn't directly use the initialize method

### `calls:`, `defines:`
_aliases `call:`, `define:`_
Describe implicitly called and defined methods using these keys. they're structured the same way:

It must have at least one of `argument:`, `itself: true`, or `keys: '*'` which points to the implied method definition/call.
This value must be a literal string, symbol, or array of strings or symbols.

#### `arguments:`
_alias `argument:`_

the position or keyword of the value or values being implicitly called/defined.
it can be a single argument or a list.

This value must be itself a literal String, Symbol, or Array or Hash whose values are Strings and Symbols or more nested Arrays and Hashes.
Variables and other method calls returning values will be ignored.

`*` means all positional arguments values. `**` means all keyword arguments values.
Positional arguments start at 1.

```yml
dynamic:
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
dynamic:
  - name: validate
    calls:
      - arguments: ['*', if, unless]
```
```ruby
validate :does_not_match_existing_record, if: :new_record?
```
will count as a call to `does_not_match_existing_record`, and `new_record?`

##### Constant assignment.

In addition to method call arguments, this can be used for constant assignment, as often constant assignment plus class_eval/instance_eval/define_method is used to dry up similar methods.
```yml
dynamic:
  - name: METHOD_NAMES
    defines:
      - arguments: 1
        add_suffix: _attributes
    calls:
      - arguments: 1
```
```ruby
METHOD_NAMES = %w{user account}.freeze
METHOD_NAMES.each do |method_name|
  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def #{method}_attributes
      self.#{method}
    end
  end
end
```
counts as a definition of `user_attributes` and `account_attributes` and calls to `user` and `account`

use `arguments: '**'`, and or `keys: true` for assigning hashes
```yml
dynamic:
  - name: METHOD_NAMES
    defines:
      - keys: '*'
        add_prefix: setup_
    calls:
      - arguments: '**'
        add_prefix: build_
```
```ruby
METHOD_NAMES = { user: :login, account: :profile }
METHOD_NAMES.each do |method_name|
  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def setup_#{method}
      build_#{method}
    end
  end
end
```
Would count as defining `setup_user`, and `setup_account` and calling `build_login` and `build_profile`

#### `itself: true`

Will supply the method/constant name itself as the thing to be transformed.
The original method/constant name will continue to be defined as normal
```yml
- name:
      has_prefix: be_
    calls:
      itself: true
      delete_prefix: be_
      add_suffix: '?'
```
```ruby
expect(value).to be_empty
```
will count `be_empty` as a call to `empty?`

#### `keys: '*'`
When the keyword argument **keywords** are the thing being called.

```yml
dynamic:
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

```yml
- name: attribute
    defines:
      - argument: 1
        transforms:
          - original # no transformation
          - add_suffix: '?'
          - add_suffix: '='
```
```ruby
attribute :first_name
```
will count as a definition of `first_name`, `first_name=` and `first_name?`

If there is just one transform for the arguments you can remove the `transforms:` keyword and move everything up a level.

```yml
- name: attr_writer
  defines:
    - argument: '*'
      add_suffix: '='
```
```ruby
attr_writer :first_name, :surname
```
will count as the definition of `first_name=`, and `surname=`

| transform | examples | effect |
| --- | --- | --- |
|original| `original`, `original: true` | no change. useful when grouped with other transforms |
|add_prefix| `add_prefix: be_`, `add_prefix: { from_argument: 'to', joiner: '_' }` | adds the prefix string. possibly from another attribute (used for rails' delegate). |
|add_suffix| `add_suffix: '?'`, `add_suffix: Validator` | adds the suffix string. possibly from another attribute. |
|delete_prefix| `delete_prefix: be_` | removes the prefix string. |
|delete_suffix| `delete_suffix: _html` | removes the suffix string. |
|delete_before| `delete_before: '#'` | removes everything up to and including the string. used for rails' routes. |
|delete_after| `delete_after: '#'` | removes everything after to and including the string. used for rails' routes. |
|replace_with| `replace_with: html` | replaces the original string, perhaps because it dynamically calls it |
|downcase| `downcase`, `downcase: true` | calls ruby's `String#downcase` |
|upcase| `upcase`, `upcase: true` | calls ruby's `String#upcase` |
|capitalize| `capitalize`, `capitalize: true` | calls ruby's `String#capitalize` |
|swapcase| `swapcase`, `swapcase: true` | calls ruby's `String#swapcase` |
|pluralize| `pluralize`, `pluralize: true` | calls activesupport's `String#pluralize` extension. Will try to load config/initializers/inflections.rb |
|singularize| `singularize`, `singularize: true` | calls activesupport's `String#singularize` extension. Will try to load config/initializers/inflections.rb |
|camelize| `camelize`, `camelize: true`, `camelcase`, `camelcase: true` | calls activesupport's `String#camelize` extension. Will try to load config/initializers/inflections.rb |
|underscore| `underscore`, `underscore: true` | calls activesupport's `String#underscore` extension. |
|demodulize| `demodulize`, `demodulize: true` | calls activesupport's `String#demodulize` extension. |
|deconstantize| `deconstantize`, `deconstantize: true` | calls activesupport's `String#deconstantize` extension. |
|titleize| `titleize`, `titleize: true`, `titlecase`, `titlecase: true` | calls activesupport's `String#titleize` extension. |
|parameterize| `parameterize`, `parameterize: true` | calls activesupport's `String#parameterize` extension. |

#### `linked_transforms:`

This is identical to `transforms:` except that a call to one of the defined methods counts as a call to them all.

```yml
- name: attribute
    defines:
      - argument: 1
        linked_transforms:
          - original # no transformation
          - add_suffix: '?'
          - add_suffix: '='
```
```ruby
attribute :first_name

def initialize
  self.first_name = 'dana'
end
```
will count as a definition of `first_name`, `first_name=` and `first_name?`, and because of `linked_transforms` the call to `first_name=` also counts as a call to `first_name?` and `first_name`

#### `if:`, `unless:`

Sometimes what to do depends on other arguments than the ones looked at:
e.g. rails' `delegate` method has a `prefix:` argument of its own that is used when defining methods:

`if:` and `unless:` work the same way and can be given a list or single value of conditions. For a list, all conditions must be met.

```yml
dynamic:
  - name: field
    calls:
      - argument: 1
        unless:
          has_argument: method
      - argument: method
```
```ruby
field :first_name
field :family_name, method: :surname
```
would count calls to `first_name`, and `surname`, but not `family_name`

##### `has_argument:`

has_argument can be given a keyword or list of keywords. or a list of patterns like name.
or to check either the exact value or type of value it can be given `keyword:` and `value:` which also match the patterns like `name:`.
instead of an exact value `value:` can be given a type or list of type.

This all comes together to give the most complex rule, rails delegate method.
```yml
dynamic:
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
