# Configuration

The configuration is read from `.leftovers.yml` in your project root.
Its presence is optional and all of these settings are optional.

- [`include_paths:`](#include_paths)
- [`exclude_paths:`](#exclude_paths)
- [`test_paths:`](#test_paths)
- [`precompile:`](#precompile)
- [`requires:`](#requires)
- [`gems:`](#gems)
- [`keep:`](#keep)
- [`test_only:](#test_only)
- [`dynamic:`](#dynamic)

see the [built in config files](https://github.com/robotdana/leftovers/tree/main/lib/config) or [this repo's own config](https://github.com/robotdana/leftovers/tree/main/.leftovers.yml) for examples.

## `include_paths:`
_alias `include_path:`_

List filenames/paths in the gitignore format of files to be checked
Defined using the [.gitignore pattern format](https://git-scm.com/docs/gitignore#_pattern_format)

By default leftovers will already check all `*.rb` files, and files with no extension and a shebang containing `ruby` e.g. (`#!/usr/bin/env ruby`)
Also the config added in [`gems:`](#gems) may add to this list, e.g. `gems: rake` adds `Rakefile` and `*.rake` to be checked.

```yml
include_paths:
  - '*.rb'
  - '*.rake'
  - Gemfile
```

Arrays are not necessary for single values

## `exclude_paths:`
_alias `exclude_path:`_

List filenames/paths that match the above that you might want to exclude
Defined using the [.gitignore pattern format](https://git-scm.com/docs/gitignore#_pattern_format)

By default leftovers will already read your project's .gitignore file and ignore anything there.

```yml
exclude_paths:
  - /some/long/irrelevant/generated/file
```

Arrays are not necessary for single values

## `requires:`
_alias `require`_

List filenames/paths that you want to include
Unlike other `paths:` configuration, each entry is **not** the gitignore pattern format.
Instead it is strings that can be passed directly to ruby's `require` method (relative paths should start with `./`).

```yml
require: ./config/initializers/my_other_inflections_file
```

Missing files/gems will be a warning, but not a LoadError.
To avoid seeing the warning if the file isn't there use `quiet:`.

```yml
  requires:
  - 'active_support/inflections' # will warn if it's missing
  - quiet: './config/initializers/inflections' # will say nothing
```

Arrays are not necessary for single values

## `test_paths:`
_alias `test_path:`_

list filenames/paths of test directories that will be used to determine if a method/etc is only tested but not otherwise used.
Defined using the [.gitignore pattern format](https://git-scm.com/docs/gitignore#_pattern_format)

```yml
test_paths:
  - /test/
  - /spec/
```

Arrays are not necessary for single values

## `precompile:`

```yml
  require: './path/my_project/my_precompiler'
  precompile:
    - paths: '*.myCustomFormat'
      format: { custom: 'MyProject::MyPrecompiler' }
    - paths: '*.my.json'
      format: json
```

Define any precompilers and the paths they affect.

`paths:` are defined using the [.gitignore pattern format](https://git-scm.com/docs/gitignore#_pattern_format)

`format:` must be one of the predefined precompilers (erb, haml, [json](#format-json), slim, [yaml](#format-yaml)), or `custom:` with the name of a [custom precompiler]('../Custom-Precompilers.md) module.
(use [`require:`](#requires) to have leftovers load its file)

See [Custom precompilers]('../Custom-Precompilers.md) for more details on the custom precompiler class

Arrays are not necessary for single values.

### `format: yaml`

The yaml precompiler considers yaml tags like `!ruby/class 'MyClass'` to be a call to `MyClass`.
and renders the structure of the yaml document as arguments for the [`document:true`](#document-true) rule.

so you could, e.g. read the class name out of a yaml document like:

```yml
class_name: MyClass
```

with config like:

```yml
include_paths:
  - 'config/*.yml'

dynamic:
  document: true
  path: config/*.yml
  calls:
    argument: class_name
```

[`nested:`](#nested) may be useful for more complex yaml structures

### `format: json`

The json precompiler renders the structure of the json document as arguments for the [`document:true`](#document-true) rule.

so you could, e.g. read the class name out of a json document like:

```json
{ "class_name": "MyClass" }
```

with config like:

```yml
include_paths:
  - 'config/*.json'

dynamic:
  document: true
  path: config/*.json
  calls:
    argument: class_name
```

[`nested:`](#nested) may be useful for more complex json structures

## `gems:`
_alias `gem:`_

By default Leftovers will look at your `Gemfile.lock` file to find all gem dependencies

If you don't use bundler, you can still take advantage of the built in handling for certain gems. The arguments should exactly match the gems name. not all gems are supported yet.

```yml
gems:
  - rspec
  - rails
```

Arrays are not necessary for single values

## `keep:`

This is a list of methods/constants/variables that are ok to be defined and not used, because they're your public api, or called by a gem on your behalf or etc.

Each entry can be a string (an exact match for a method, constant, or variable name that includes the sigil), or have at least one of the following properties:
- [`names:`](#names)
  or the properties from `names:`
  - [`has_prefix:`](#has_prefix)
  - [`has_suffix:`](#has_suffix)
  - [`matches:`](#matches)
- [`paths:`](#paths)
- [`has_arguments:`](#has_arguments)
- [`has_receiver:`](#has_receiver)
- [`type:`](#type)
- [`privacy:`](#privacy)
- [`unless`](#unless)

Arrays are not necessary for single values

example from rails.yml
```yml
keep:
  - APP_PATH
  - ssl_configured?
  - has_suffix: Helper
    path: /app/helpers
  ...
```

Alternatively, you can mark method/constants/variables in-place using [magic comments](https://github.com/robotdana/leftovers/tree/main/README.md#magic-comments).

## `test_only:`

This is a list of methods/constants/variables that are ok to be defined outside of [test paths](#test_paths), but only used within test paths, maybe because they're your public api, or convenience methods for tests etc.

Each entry can be a string (an exact match for a method, constant, or variable name that includes the sigil), or have at least one of the following properties:
- [`names:`](#names)
  or the properties from `names:`
  - [`has_prefix:`](#has_prefix)
  - [`has_suffix:`](#has_suffix)
  - [`matches:`](#matches)
- [`paths:`](#paths)
- [`has_arguments:`](#has_arguments)
- [`unless`](#unless)

Arrays are not necessary for single values

example from rails.yml
```yml
test_only:
  - APP_PATH
  - ssl_configured?
  - has_suffix: Helper
    path: /app/helpers
  ...
```

Alternatively, you can mark method/constants/variables in-place using [magic comments](https://github.com/robotdana/leftovers/tree/main/README.md#magic-comments).

## `dynamic:`

This is a list of methods, constants, or variables whose called arguments or assigned value/s are used to dynamically `call:` or define (`define:`) other methods, constants, or variables

Each entry must have at least one of the following properties to restrict which method/constant/variable this applies to:
- [`names:`](#names)
  or the properties from `names:`
  - [`has_prefix:`](#has_prefix)
  - [`has_suffix:`](#has_suffix)
  - [`matches:`](#matches)
- [`paths:`](#paths)
- [`has_arguments:`](#has_arguments)
- [`has_receiver:`](#has_receiver)
- [`unless:`](#unless)
- [`document: true`](#document-true)

And must have at least one of
- ['calls:`](#calls-defines)
- [`defines:`](#calls-defines)
- [`set_privacy:](#set-privacy)
- [`set_default_privacy:`](#set-default-privacy)

Arrays are not necessary for single values.

example from the default ruby.yml
```yml
dynamic:
  - name: attr_accessor
    defines:
      - arguments: '*'
        add_suffix: '='
      - arguments: '*'
    calls:
      arguments: '*'
      add_prefix: '@'
    ...
```

## `names:`
_alias `name:`_

This is a list of methods/constants/variables, and can be used in [`dynamic:`](#dynamic) and [`keep:`](#keep)

Each entry can be a string (an exact match for a method, constant, or variable name that includes the sigil), or have at least one of the following properties:
- [`has_prefix:`](#has_prefix)
- [`has_suffix:`](#has_suffix)
- [`matches:`](#matches)

Arrays are not necessary for single values

example from rails.yml
```yml
keep:
  - APP_PATH
  - ssl_configured?
  - names:
      has_suffix: Helper
    path: /app/helpers
  ...
```

## `has_prefix:`, `has_suffix:`

To match strings other than exact strings, you can use has_suffix or has_prefix or both if you're feeling fancy.

This can be in entries in:
- [`dynamic:`](#dynamic), [`keep:`](#keep), [`names:`](#names) to match method/constant/variable names
- [`has_arguments:`](#has_arguments), [`arguments:`](#arguments), [`keywords:`](#keywords), [`at:`](#at) to match keyword argument names (whether they're symbols or strings)
- [`has_values:`](#has_values) to match argument/assigned values (whether they're symbols or strings)

```yml
keep:
  - has_suffix: Helper # will match Helper, LinkHelper FormHelper, etc
  - has_prefix: be_ # will match be_equal, be_invalid, etc
  - { has_prefix: is_, has_suffix: '?' } # will match is_invalid?, is_equal? etc
```

## `matches:`
_alias `match:`_

if [`has_suffix:`](#has_prefix-has_suffix) and [`has_prefix:`](#has_prefix-has_suffix) isn't enough, you can use `matches:` to supply a regex

This string is converted into an anchored ruby regexp and must match the whole string, see [ruby's regex documentation](https://ruby-doc.org/core-2.7.2/Regexp.html#class-Regexp-label-Metacharacters+and+Escapes) for the syntax.

This can be in used for entries in:
- [`dynamic:`](#dynamic), [`keep:`](#keep), [`names:`](#names) to match method/constant/variable names
- [`has_arguments:`](#has_arguments), [`arguments:`](#arguments), [`keywords:`](#keywords) to match keyword argument names (whether they're symbols or strings in the code)

```yml
dynamic:
  - names:
      matches: 'row_\d+' # will match row_1, row_2, row_99, but not row_1a, or crow_1, or etc.
    calls:
      argument:
        matches: 'column_\d+' # will match column_1, column_2, column_99, but not column_first etc
```

## `paths:`
_alias `path:`_

An list of paths, defined using the [.gitignore pattern format](https://git-scm.com/docs/gitignore#_pattern_format)

This can be used in entries in [`dynamic:`](#dynamic), [`keep:`](#keep)

Arrays are not necessary for single values

```yml
keep:
  - name:
      - has_suffix: Helper
    path: /app/helpers
```

## `document: true`

Instructs to consider the whole document. this is useful when parsing [YAML](#yaml-paths) or [JSON](#json-paths) config files for various values.

e.g.

```yml
includes: /config/roles.yml
dynamic:
  - document: true
    path: /config/roles.yml
    defines:
      arguments: '*'
      add_suffix: '?'
      add_prefix: can_
```

will parse "config/roles.yml"
```yml
- build_house
- drive_car
```

and consider it to have created methods like `can_build_house?` and `can_drive_car?`

[`nested:`](#nested) may be useful for more complex data structures

## `calls:`, `defines:`
_aliases `call:`, `define:`_

These may be used as entries in [`dynamic:`](#dynamic)

This is a list of values that are called or defined dynamically by the matched method, or eventually after being assigned to the the matched constant or variable.

Each entry must be have at least one the these properties:
- [`arguments:`](#arguments)
- [`keywords:`](#keywords) keyword argument keywords, and assigned hash keys
- [`itself: true`](#itself-true) the matched name (intended to be used with `transforms:`, as the untransformed matched name will already be tracked)
- [`value:`](#value) a literal string to be called/defined

also there may be any or all of these properties:
- [`nested:`](#nested) (only with `arguments:`)
- [`recursive: true`](#recursive-true) (only with `arguments:`)
- [`transforms:`](#transforms)
  - or any these properties for `transform:`
  - [`add_prefix:`](#add_prefix-add_suffix)
  - [`add_suffix:`](#add_prefix-add_suffix)
  - [`delete_prefix:`](#delete_prefix-delete_suffix)
  - [`delete_suffix:`](#delete_prefix-delete_suffix)
  - [`delete_before:`](#delete_before-delete_after)
  - [`delete_after:`](#delete_before-delete_after)
  - [`split:`](#split)
  - [`downcase:`](#downcase-upcase-capitalize-swapcase)
  - [`upcase:`](#downcase-upcase-capitalize-swapcase)
  - [`capitalize:`](#downcase-upcase-capitalize-swapcase)
  - [`swapcase:`](#downcase-upcase-capitalize-swapcase)
  - [`pluralize:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)
  - [`singularize:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)
  - [`camelize:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)
  - [`underscore:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)
  - [`demodulize:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)
  - [`deconstantize:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)
  - [`titleize:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)
  - [`parameterize:`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore)

Arrays are not necessary for single values and if the rule contains only `arguments:` the keyword can be omitted, and everything moved up a level

```yml
dynamic:
  - name:
      - send
    calls:
      arguments:
        - 1
```
is equivalent to:
```yml
dynamic:
  name: send
  calls: 1
```

## `set_privacy:`

Set privacy has the same requirements as [`calls:` & `defines:`](#calls-defines).

additional it requires a `to:` with one of either `private`, `public`, or `protected`.

For example, from the ruby config:
```yml
dynamic:
  name: private_class_method
  has_argument: 0
  set_privacy:
    argument: '*'
    to: private
```

which sets all methods named by the arguments to the privacy_class_method method to private.

these methods could then be filtered using the [`privacy:`](#privacy) method in another [`dynamic:`](#dynamic) or [`keep:`](#keep) rule.

Leftovers limits this to only affect methods defined in the same file.

## `set_default_privacy:`

This must be one of `public`, `private`, or `protected` and will set all subsequent method definitions in this file to that default privacy (unless its then overridden by [`set_privacy`](#set_privacy))

For example, from the default ruby config:
```yml
dynamic:
  name: private
  unless:
    has_argument: 0
  set_default_privacy: private
```

these methods could then be filtered using the [`privacy:`](#privacy) method in another [`dynamic:`](#dynamic) or [`keep:`](#keep) rule.

## `arguments:`
_alias `argument:`_

Each entry indicates the position or keyword of the value or values in either a list of method call arguments, or a literal array or hash
and when used in:
- [`calls:`](#calls-defines), [`defines:`](#calls-defines) or [`nested:`](#nested) to filter method/constant/variable names are supplied [`transforms:`](#transforms), or [`nested:`](#nested)
- [`add_prefix:`](#add_prefix), [`add_suffix:`](#add_suffix) the argument value can be used as the prefix/suffix rather than a literal string

It can have any of these properties:
- [`at:`](#at)
- [`has_value:`](#has_value_has_receiver)

Arrays are not necessary for single values and if the rule contains only `at:` it can be omitted, and the values moved up a level.

Positional arguments are zero indexed

## `has_arguments:`
_alias `has_argument:`_

Each entry indicates the position or keyword of the value or values in either a list of method call arguments, or a literal array or hash
and when used in:
- [`dynamic:`](#dynamic) it uses the presence of matching arguments to filter which methods calls/constant/variable assignments are processed
- [`keep:`](#keep) it uses the presence of matching arguments to filter which methods calls/constant/variable assignments are skipped

The method call/constant variable/assignment will be considered matching if it has **any** of these arguments/assigned values.

It can have any of these properties:
- [`at:`](#at)
- [`has_value:`](#has_value_has_receiver)

Arrays are not necessary for single values and if the rule contains only `at:` it can be omitted, and the values moved up a level

Positional arguments are zero indexed

## `keywords:`
When the keyword argument **keywords** are the thing being called.

```yml
dynamic:
  - name: validates
      calls:
        - arguments: '*'
        - keywords: '**'
          camelize: true
          add_suffix: Validator
```
```ruby
validates :first_name, :surname, presence: true
```
will count calls for `validates`, `first_name`, `surname`, and `PresenceValidator`

## `at:`

Each entry indicates the position or keyword of the value or values in either a list of method call arguments, or a literal array or hash.

This can be used in:
- [`has_arguments`](#has_arguments) to filter method calls/constant/variable assignments by the presence of this argument
- [`arguments:`](#arguments) to select positional argument values and keyword **values** to be processed
- [`keywords:`](#keywords) to select **keywords** and hash **keys** to be processed

Each entry can be any of:
- `'*'`: matches all positional arguments/array positions
- `'**'`: matches all keyword arguments/hash positions
- any positive Integer: matches the 1-indexed argument position/array position
- any other String: matches the keyword argument or hash value, where the keyword/hash key string or symbol
- or have at least one of the following properties to match the keyword/hash key string or symbol:
  - [`has_prefix:`](#has_prefix)
  - [`has_suffix:`](#has_suffix)
  - [`matches:`](#matches)

Arrays are not necessary for single values

## `has_value:`, `has_receiver:`

filter [`arguments:`](#arguments), [`has_arguments:`](#has_arguments), and [`keywords:`](#keywords), by the argument/assigned/receiver value

Each entry can be one of
- `true`, `false`, `nil`, or an Integer. matches the literal value
- a String. matches the literal string or symbol value
- or have at least one of the following properties to match the name:
  - [`has_prefix:`](#has_prefix)
  - [`has_suffix:`](#has_suffix)
  - [`matches:`](#matches)
- or have at least one of the following properties to match within an array or hash:
  - [`at`](#at)
  - [`has_value`](#has_value_has_receiver)
- or have the following property to match the value type
  - [`type`](#type)
- or have the following property to match the receiver
  - [`has_receiver`](#has_value_has_receiver)

## `privacy:`

filter [`dynamic:`](#dynamic) and [`keep:`](#keep) by method/constant privacy

e.g.

```yml
keep:
  - path: '**/generators/**/*_generator.rb'
    privacy: public
    type: Method
```

considers all public methods defined in rails generators to be called.

## `type:`

Filter by the literal type

Each entry can be one of
- `'String'` a literal string, defined with "" or '' (not String.new)
- `'Symbol'` a literal symbol
- `'Integer'` a literal integer
- `'Float'` a literal float
- `'Array'` a literal array defined with [] (not Array.new)
- `'Hash'` a literal hash, defined with {} (not Hash.new)
- `'Proc'` a literal proc/lambda, defined with lambda {}, proc {}, or -> {} (not Proc.new)
- `'Method'` a method call or definition defined with def, (not define_method {})
- `'Constant'` a constant assignment, or a literal module or class defined with keywords, (not Module/Class.new)

Arrays are not necessary for single values

## `nested:`

To process an argument that is an array you will need to supply which entries in the array need processing.

This can be used in [`calls:`](#calls-defines), [`defines:`](#calls-defines) or within a preceding `nested:` entry

Each entry must be have at least one the these properties:
- [`arguments:`](#arguments)
- [`keywords:`](#keywords) keyword argument keywords, and assigned hash keys
And may additionally have any of these properties:
- [`nested:`](#nested)
- [`recursive: true`](#recursive-true)

It will filter the arrays/hashes found by its sibling properties `arguments:`, and `keywords:`, using its own child properties.

e.g.
```yml
dynamic:
  - names: my_method
    calls:
      argument: 2
      nested:
        argument: '*'
        nested:
          argument: name
```
```ruby
my_method([{name: :name_1}, {name: :name_2}, [{name: :name_3, value: :value_1}, {name: :name_4, value: :value_2}])
```
will count `name_3`, and `name_4` (but not `name_1` and `name_2` because they're within the first positional argument, and not `value_1`, or `value_2`)

Arrays are not necessary for single values

## `recursive: true`

This can be used in [`calls:`](#calls-defines), [`defines:`](#calls-defines) or within a preceding [`nested:`](#nested) entry

Similar to [`nested:`](#nested), this processes arrays hashes found by its sibling [`arguments:`](#arguments) and [`keywords:`](#keywords) properties, with those same properties, recursively.

e.g. rails' ActiveRecord::Base#joins method can call association methods using all positional arguments values, keyword argument keywords and values, and recursively all values arrays and hash keys and values
```yml
dynamic:
  name: [joins, left_joins]
  calls:
    arguments: ['*', '**']
    keywords: '**'
    recursive: true
```

## `itself: true`

Will supply the method/constant/variable name itself as the thing to be transformed.
The original method/constant/variable name will continue to be called/defined as normal

This can be used in [`calls:`](#calls-defines) and [`defines:`](#calls-defines)

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

## `value:`

Will supply a literal string value method/constant/variable name itself as the thing to be called/defined.
This can be used in [`calls:`](#calls-defines) and [`defines:`](#calls-defines).

```yml
- name: perform_async
  calls:
    value: perform
```
```ruby
MyWorker.perform_async
```
will count `perform_async` as a call to `perform`

## `transforms:`

Sometimes the method/class being called is modified from the literal argument, sometimes that's just appending an `=` and sometimes it's more complex:

Each entry can have a string that is an argumentless transform (e.g. capitalize) or a hash with transform keywords. This can be in used for entries in:
- [`defines:`](#calls-defines), [`calls:`](#calls-defines) to modify values filtered by the sibling keys [`arguments:`](#arguments), [`keywords:`](#keywords) and [`itself: true`](#itself-true) (also [`value:`](#value) but as that's a literal value anyway, why would you)
- [`add_prefix:`](#add_prefix-add_suffix), [`add_suffix:`](#add_prefix-add_suffix) to modify the selected `argument:` or `keyword:` for dynamic prefixes and suffixes

- [`original`](#original) or `original: true`
- [`add_prefix:`](#add_prefix-add_suffix)
- [`add_suffix:`](#add_prefix-add_suffix)
- [`delete_prefix:`](#delete_prefix-delete_suffix)
- [`delete_suffix:`](#delete_prefix-delete_suffix)
- [`delete_before:`](#delete_before-delete_after)
- [`delete_after:`](#delete_before-delete_after)
- [`split:`](#split)
- [`downcase`](#downcase-upcase-capitalize-swapcase) or `downcase: true`
- [`upcase`](#downcase-upcase-capitalize-swapcase) or `upcase: true`
- [`capitalize`](#downcase-upcase-capitalize-swapcase) or `capitalize: true`
- [`swapcase`](#downcase-upcase-capitalize-swapcase) or `swapcase: true`
- Also, if you have the active_support gem available:
  - [`pluralize`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `pluralize: true`
  - [`singularize`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `singularize: true`
  - [`camelize`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `camelize: true`
  - [`underscore`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `underscore: true`
  - [`demodulize`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `demodulize: true`
  - [`deconstantize`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `deconstantize: true`
  - [`titleize`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `titleize: true`
  - [`parameterize`](#pluralize-singularize-camelize-demodulize-deconstantize-parameterize-titleize-underscore) or `parameterize: true`

If any one of these `transforms:` entries are used, all count as being used. To have these be counted independently instead, create multiple entries in the `defines:` list.

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
will count as a definition of `first_name`, `first_name=` and `first_name?`. `firstname=` wouldn't be reported on, even if only `first_name` and `first_name?` were used.

Arrays are not necessary for single values, and if there is just one set of transforms, the `transforms:` keyword can be omitted and everything moved up a level.

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

## `original`

Can be used in the [`transforms:`](#transforms) list, if used in a hash `true` can be used as a placeholder value

This performs no change, and is only useful when grouped with other transforms

## `add_prefix:`, `add_suffix:`

Can be used in the [`transforms:`](#transforms) list (or anywhere `transforms:` is able to be omitted).

Each entry is one of:
- a literal string
- [`argument:`](#argument) or [`keyword:`](#keyword) matching arguments/assignments from the original method call/method definition
- Optionally [`transform:`] or any of the `transform:` properties, to transform the value(s) from `argument:` and `keyword:`.

if multiple transform results are possible (from multiple entries, or multiple matching arguments or etc), then all results will be used.

Arrays are not necessary for single values

## `delete_prefix:`, `delete_suffix:`

Can be used in the [`transforms:`](#transforms) list (or anywhere `transforms:` is able to be omitted).

Each entry is a literal string, and _if present_ the matching prefix or suffix will be removed (if it's not present, this transform will continue to the next transform/result unmodified)

if multiple transform results are possible (from multiple entries), then all results will be used.

Arrays are not necessary for single values

## `delete_before:`, `delete_after:`

Can be used in the [`transforms:`](#transforms) list (or anywhere `transforms:` is able to be omitted).

Each entry is a literal string, and _if present_ the string and everything before/after will be removed from the incoming value (if it's not present, this transform will continue to the next transform/result unmodified). if it's present multiple times then it will always be everything before/after the first substring match

if multiple transform results are possible (from multiple entries), then all results will be used.

Arrays are not necessary for single values

## `split:`

Can be used in the [`transforms:`](#transforms) list (or anywhere `transforms:` is able to be omitted).

Each entry is a literal string, and _if present_ the incoming value will string will be split on this value. (if it's not present, this transform will continue to the next transform/result unmodified)

if multiple transform results are possible (from multiple entries), then all results will be used.

Arrays are not necessary for single values

## `downcase`, `upcase`, `capitalize`, `swapcase`

Can be used in the [`transforms:`](#transforms) list (or anywhere `transforms:` is able to be omitted).
if used in a hash `true` can be used as a placeholder value

the incoming value will be transformed using the [core ruby String method](https://ruby-doc.org/core-2.6/String.html#method-i-capitalize)

## `pluralize`, `singularize`, `camelize`, `demodulize`, `deconstantize`, `parameterize`, `titleize`, `underscore`
_aliases `camelcase`, `titlecase`_

Can be used in the [`transforms:`](#transforms) list (or anywhere `transforms:` is able to be omitted).
if used in a hash `true` can be used as a placeholder value

the incoming value will be transformed using the [active_support String core extensions](https://edgeguides.rubyonrails.org/active_support_core_extensions.html#inflections)
and if using [gems:](#gems) with `activesupport` or `rails` then your `config/initializers/inflections.rb` will be loaded. if you have inflections in another file, then supply that to [`requires:`](#requires).

If the `activesupport` gem is not available this will raise an error.

## `unless:`

It will filter the values found by its sibling properties, whatever they are, removing anything that matches its own child properties.
if it has no sibling properties, then it's filtering everything to remove anything that matches it's own child properties.

Each entry is able to have child properties drawn from whatever the unless keyword's sibling properties are able to be

Arrays are not necessary for single values
