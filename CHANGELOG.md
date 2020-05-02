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
