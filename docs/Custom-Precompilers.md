# Custom Precompilers

In addition to the built in precompilers, it's possible to add a custom precompiler

It must be a class or module with a singleton method `precompile`. take a string of whatever code it likes, and return a string of valid ruby.

```ruby
require 'not_ruby' # require the gem that does the actual transformation

module MyNotRubyPrecompiler
  def self.precompile(not_ruby_content)
    # not_ruby_content is a string of (hopefully) valid precompilable code
    NotRuby::Parser.parse(not_ruby_content).to_ruby # output a string of valid ruby
  end
end
```

See the [build in precompilers](https://github.com/robotdana/leftovers/tree/main/lib/precompilers) for other examples.

To configure the precompiler to be used by leftovers, add something similar to this to the `.leftovers.yml` file

```yml
  include_paths:
    - 'lib/**/*.not_rb'
  require: './path/to/my_not_ruby_precompiler'
  precompile:
    - paths: '*.not_rb'
      format: { custom: MyNotRubyPrecompiler }
```

Ensure any necessary extension patterns are added to to [`include_paths:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#include_paths) for those particular files you wish to check.

Require the custom precompiler using [`require:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#requires)

Define which paths use the custom precompiler using [`precompile:`](https://github.com/robotdana/leftovers/tree/main/docs/Configuration.md#precompile),
reference the name of the precompiler with `format: { custom: MyNotRubyPrecompiler }`

If the `precompile` method raises any errors while precompiling, a warning will be printed to stderr and the file will be skipped
