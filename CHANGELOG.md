
# v0.4.0
- REFACTORED EVERYTHING for a codebase i actually can extend
- Now with a tweaked config api
  - `rules: calls/defines: arguments: if/unless:` is now `rules: has_arguments:` and `rules: unless: has_arguments:` (see config/graphql.yml field)
  - `rules: calls/defines: transforms: replace_with:` is now `rules: calls/defines: value:` (see custom_config_spec.rb html)
  - `rules: names: [names],skip: true` is now `keep: [names]` (see config/parser.yml)
  - `rules: calls/defines: transforms: add_prefix: from_argument:,joiner:` is now `rules: calls/defines: transforms: add_prefix: argument:,add_suffix:` (see config/rails.yml delegate)
  - `rules: calls/defines: linked_transforms:` is now `rules: calls/defines: transforms:` (see config/rails.yml attribute). For the previous behaviour of `transforms:` add separate calls/defines entry. (see config/ruby.yml attr_accessor)
  - `rules: keys: true` is now `rules: keywords: '**'` and can be given name patterns (e.g. unless:. see config/rails.yml validates)
  - no more automatic recursion, there's now two new keywords:
    - `rules: calls/defines: arguments/keys:,nested: arguments/keys:` will define the next layer of arguments to collect (see config/rails.yml validates)
    - `rules: calls/defines: arguments/keys:,recursive: true` will use the arguments & keys layers recursively (see config/rails.yml permit)
  - no more automatic splitting on ':' and '.', there's now a `rules: calls/defines: transforms: split: '::'` (see config/rails.yml resource)

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
