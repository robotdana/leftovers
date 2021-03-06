# v0.4.4
- don't hard-wrap the --write-todo instructions it looks weird

# v0.4.3
- add --write-todo so you can add this to your project without
immediately fixing everything.

# v0.4.2
- Make sorbet happy with this as a dependency
# v0.4.1
- add `test_only:` to mark methods/constants/assignments as test_only in the config rather than just with magic comments

# v0.4.0
- add `requires:` to .leftovers.yml config to e.g. load inflections in a different place than `config/initializers/inflections`
- REFACTORED EVERYTHING for a codebase i actually can extend
- Now with a very modified config api. After this i don't intend on every doing a rewrite like this again, so this is correcting all my bad decisions the first time through
  - `rules.names` with `rules.skip: true` is now `keep.names` (see config/parser.yml)
  - `rules.calls` and `rules.defines` is now `dynamic.calls` and `dynamic.defines`
  - `rules.calls/defines.arguments.if` is now `keep/dynamic.calls/defines.has_arguments:` (see config/graphql.yml field)
  - `rules.calls/defines.arguments.unless` is now `keep/dynamic.unless.has_arguments` (see config/graphql.yml field)
  - `rules.calls/defines.transforms.replace_with` is now `keep/dynamic.calls/defines.value` (see custom_config_spec.rb html)
  - `rules.calls/defines.transforms.add_prefix.from_argument/joiner:` is now `dynamic.calls/defines.transforms.add_prefix.argument/add_suffix` (see config/rails.yml delegate)
  - `rules.calls/defines.transforms.add_suffix.from_argument/joiner:` is now `dynamic.calls/defines.transforms.add_suffix.argument/add_prefix`
  - `rules.calls/defines.key: true` is now `dynamic.calls/defines.keywords: '**'`
  - `rules.calls/defines.arguments.if.arguments.value` is now `keep/dynamic.has_arguments.has_value`
  - `rules.calls/defines.arguments.if.arguments.value.type` is now `keep/dynamic.has_arguments.has_value_type`
  - `rules.calls/defines.linked_transforms` is now `dynamic.calls/defines.transforms` (see config/rails.yml attribute). For the previous behaviour of the `transforms:` key simply add separate calls/defines entry. (see config/ruby.yml attr_accessor)
  - `rules.calls/defines.keys: true` is now `dynamic.calls/defines.keywords: '**'` and can be given name patterns (e.g. unless:. see config/rails.yml validates)
  - argument positions are now 0-indexed rather than 1-indexed
  - no more automatic recursion, there's now two new keywords:
    - `dynamic.calls/defines.arguments/keywords` with `dynamic.calls/defines.nested.arguments/keywords` will define the next layer of arguments to collect (see config/rails.yml validates)
    - `dynamic.calls/defines.arguments/keywords` with `dynamic.calls/defines.recursive: true` will use the arguments & keywords layers recursively (see config/rails.yml permit)
  - no more automatic splitting on ':' and '.', there's now a `dynamic.calls/defines.transforms.split: '::'` (see config/rails.yml resource)

# v0.3.0
- Add simplecov, fix a handful of bugs it found
- update fast_ignore

# v0.2.4
- use the right name for selenium-webdriver gem, so the bundler magic can work
- handle yaml syntax errors.

# v0.2.3
- restore ability to handle syntax errors. I really need to add coverage to this project
- Fix bug with delete_after on an empty string
- Support more of rails
- Support parts of sidekiq

# v0.2.2
- update fast_ignore dependency

# v0.2.1

- Fix route arguments with '/' handling (e.g get `'/admin', to: 'admin/dashboard#index'`)
- Fix route arguments for `root to: "whatever#index"`
- Add some more rails exceptions (`APP_ROOT`, `APP_PATH`, Mailer Previews)
- add more ruby object methods that are called by various bits of ruby
- correct output of unused definitions using `linked_transforms:`
- add `audited` gem

# v0.2.0

Play nice with rubocop

# v0.1.0

Initial release
