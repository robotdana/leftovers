# frozen_string_literal: true

require 'did_you_mean' # force 2.5 and 2.6 to have suggestions.

RSpec.describe Leftovers::Config do
  before { Leftovers.reset }

  describe '.dynamic' do
    it 'can report config parse errors' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name: my_method
            - calls:
            arguments: 1
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SyntaxError: lib/config/invalid.yml:2:5 did not find expected key while parsing a block mapping\e[0m
      MESSAGE
    end

    it 'can report errors with transform dynamic affix dynamic' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name: my_method
            calls:
              arguments: 1
              add_prefix:
                arg_men: foo
                joiner: baz
      YML

      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:6:8 unrecognized key arg_men for add_prefix
        Did you mean: arguments
        Config SchemaError: lib/config/invalid.yml:7:8 unrecognized key joiner for add_prefix
        Did you mean: arguments, keywords, itself, nested, value, receiver, recursive, has_arguments, has_receiver, unless, all, any, transforms, original, pluralize, singularize, camelize, underscore, titleize, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, delete_before_last, delete_after, delete_after_last\e[0m
      MESSAGE
    end

    it 'can report errors with transform dynamic dynamic' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name: my_method
            defines:
              arguments: 1
              delete_prefix:
                argument: foo
                add_prefix: baz
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:6:8 delete_prefix must be a string or an array\e[0m
      MESSAGE
    end

    it 'can report errors with transform keys' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name:
            - my_method
            - my_other_method
            defines:
              arguments: 1
              transforms:
                infix: how
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:8:8 unrecognized key infix for transforms
        Did you mean: original, pluralize, singularize, camelize, underscore, titleize, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, delete_before_last, delete_after, delete_after_last, transforms\e[0m
      MESSAGE
    end

    it 'can report errors with invalid transform values' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name:
            - my_method
            - my_other_method
            defines:
              arguments: 1
              transforms:
                - add_prefix
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:8:10 transforms value add_prefix must be a hash key\e[0m
      MESSAGE
    end

    it 'can report errors with invalid typo transform values' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name:
            - my_method
            - my_other_method
            defines:
              arguments: 1
              transforms:
                - origin
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:8:10 unrecognized value origin for transforms value
        Did you mean: original or a hash with any of original, pluralize, singularize, camelize, underscore, titleize, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, delete_before_last, delete_after, delete_after_last, transforms\e[0m
      MESSAGE
    end

    it 'can report errors when using name and names' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names: my_other_method
            name: my_method
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:4 keep value must only use one of names or name
        Config SchemaError: lib/config/invalid.yml:3:4 keep value must only use one of names or name\e[0m
      MESSAGE
    end

    it 'can report errors when using path and paths' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names: my_method
            path: ./app
            paths: ./lib
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:3:4 keep value must only use one of path or paths
        Config SchemaError: lib/config/invalid.yml:4:4 keep value must only use one of path or paths\e[0m
      MESSAGE
    end

    it 'can report errors when using call and calls' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            calls:
              argument: 1
            call:
              argument: 2
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:3:4 dynamic value must only use one of calls or call
        Config SchemaError: lib/config/invalid.yml:5:4 dynamic value must only use one of calls or call\e[0m
      MESSAGE
    end

    it 'can report errors when using define and defines' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines:
              argument: 1
            define:
              argument: 2
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:3:4 dynamic value must only use one of defines or define
        Config SchemaError: lib/config/invalid.yml:5:4 dynamic value must only use one of defines or define\e[0m
      MESSAGE
    end

    it 'can report errors when using define and defines and call and calls' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines: 1
            define: 2
            calls: 1
            call: 2
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:3:4 dynamic value must only use one of defines or define
        Config SchemaError: lib/config/invalid.yml:4:4 dynamic value must only use one of defines or define
        Config SchemaError: lib/config/invalid.yml:5:4 dynamic value must only use one of calls or call
        Config SchemaError: lib/config/invalid.yml:6:4 dynamic value must only use one of calls or call\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid conditions' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            tuesday: true
            calls:
              argument: 1
      YML

      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:3:4 unrecognized key tuesday for dynamic value
        Did you mean: paths, document, has_arguments, has_receiver, type, privacy, unless, all, any, define, set_privacy, set_default_privacy, eval\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid argument values' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            calls:
              argument: true
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:4:16 argument must be a string or an integer or a hash with any of match, has_prefix, has_suffix, type, unless or an array\e[0m
      MESSAGE
    end

    it 'can report errors when using argument and arguments' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines:
              argument: 1
              arguments: kw
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:4:6 defines must only use one of argument or arguments
        Config SchemaError: lib/config/invalid.yml:5:6 defines must only use one of argument or arguments\e[0m
      MESSAGE
    end

    it 'can report errors when using keyword and keywords' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines:
              keyword: '**'
              keywords: '**'
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:4:6 defines must only use one of keyword or keywords
        Config SchemaError: lib/config/invalid.yml:5:6 defines must only use one of keyword or keywords\e[0m
      MESSAGE
    end

    it 'can report errors when match has an invalid regex' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          matches: '***'
      YML

      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:11 matches must be a string with a valid ruby regexp (target of repeat operator is not specified: /***/)\e[0m
      MESSAGE
    end

    it 'can report errors when match has an non-string value' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          matches: 5
      YML

      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:11 matches must be a string with a valid ruby regexp\e[0m
      MESSAGE
    end

    it 'can report errors when using missing argument etc' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines:
              add_suffix: foo
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:4:6 defines must include at least one of arguments, keywords, itself, value, receiver or an array\e[0m
      MESSAGE
    end

    it 'can report errors when using nonexistent keys for calls' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            calls:
              param: foo
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:4:6 unrecognized key param for calls
        Did you mean: arguments, keywords, itself, nested, value, receiver, recursive, has_arguments, has_receiver, unless, all, any, transforms, original, pluralize, singularize, camelize, underscore, titleize, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, delete_before_last, delete_after, delete_after_last\e[0m
      MESSAGE
    end

    it 'can report errors when using nonexistent keys for defines' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines:
              param: foo
              keyword: bar
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:4:6 unrecognized key param for defines
        Did you mean: arguments, itself, nested, value, receiver, recursive, has_arguments, has_receiver, unless, all, any, transforms, original, pluralize, singularize, camelize, underscore, titleize, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, delete_before_last, delete_after, delete_after_last\e[0m
      MESSAGE
    end

    it 'can report errors when using nonexistent keys for name' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names:
              starts_with: my_method
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:3:6 unrecognized key starts_with for names
        Did you mean: match, has_prefix, has_suffix, unless\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid vales for name' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names: 1.0
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:11 names must be a string or a hash with any of match, has_prefix, has_suffix, unless or an array\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid value number for has prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: 1.0
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:16 has_prefix must be a string\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid value integer for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: 1
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:16 has_prefix must be a string\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid value array for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: []
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:16 has_prefix must be a string\e[0m
      MESSAGE
    end

    it 'can report errors for empty keep object' do
      config = described_class.new('invalid', content: <<~YML)
        keep: {}
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:1:6 keep must include at least one of match, has_prefix, has_suffix, names, paths, document, has_arguments, has_receiver, type, privacy, all, any, unless or an array\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid value true for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: true
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:16 has_prefix must be a string\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid value null for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: null
      YML
      expect { catch(:leftovers_exit) { config.keep } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:2:16 has_prefix must be a string\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid values array for has_value' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: fancy
            has_argument:
              has_value: [[]]
            calls:
              argument: 1
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:4:18 has_value value must be any scalar value or a hash with any of names, match, has_prefix, has_suffix, has_arguments, at, has_value, has_receiver, type, unless\e[0m
      MESSAGE
    end

    it 'can report errors when using invalid value for has_value_type' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: fancy
            has_argument:
              has_value:
                type:
                  class: String
            calls:
              argument: 1
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(<<~MESSAGE).to_stderr
        \e[2K\e[31mConfig SchemaError: lib/config/invalid.yml:6:10 type must be a string or an array\e[0m
      MESSAGE
    end

    it 'can report errors when using unavailable precompilers' do
      config = described_class.new('invalid', content: <<~YML)
        precompile:
          - format: { custom: MyPrecompiler }
            paths: '*.txt'
      YML
      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .to throw_symbol(:leftovers_exit).and(output(<<~MESSAGE).to_stderr)
          \e[2K\e[31mTried using ::MyPrecompiler, but it wasn't available.
          add its path to `requires:` in your .leftovers.yml
          \e[0m
        MESSAGE
    end

    it 'can define custom precompilers with leading ::' do
      config = described_class.new('invalid', content: <<~YML)
        precompile:
          - format: { custom: "::Leftovers::Precompilers::Haml" }
            paths: '*.my.haml'
      YML
      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .not_to throw_symbol(:leftovers_exit)
    end

    it 'can define custom precompilers with no leading ::' do
      config = described_class.new('invalid', content: <<~YML)
        precompile:
          - format: { custom: "Leftovers::Precompilers::Haml" }
            paths: '*.my.haml'
      YML
      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .not_to throw_symbol(:leftovers_exit)
    end

    it 'can print a deprecation warning with haml_paths and continue' do
      config = described_class.new('invalid', content: <<~YML)
        haml_paths: '*.my.haml'
      YML

      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .to output(<<~MESSAGE).to_stderr
          \e[2K\e[33m`haml_paths:` is deprecated\e[0m
          Replace with:
          \e[32mprecompile:
          - paths: "*.my.haml"
            format: haml
          \e[0m
        MESSAGE

      expect(config.precompile)
        .to eq([{ paths: '*.my.haml', format: :haml }])
    end

    it 'can print a deprecation warning with haml_paths and slim_paths and continue' do
      config = described_class.new('invalid', content: <<~YML)
        haml_paths: '*.my.haml'
        slim_paths: '*.my.slim'
      YML

      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .to output(<<~MESSAGE).to_stderr
          \e[2K\e[33m`haml_paths:` is deprecated\e[0m
          Replace with:
          \e[32mprecompile:
          - paths: "*.my.haml"
            format: haml
          \e[0m
          \e[2K\e[33m`slim_paths:` is deprecated\e[0m
          Replace with:
          \e[32mprecompile:
          - paths: "*.my.slim"
            format: slim
          \e[0m
        MESSAGE

      expect(config.precompile)
        .to eq([{ paths: '*.my.haml', format: :haml }, { paths: '*.my.slim', format: :slim }])
    end

    it 'can print a deprecation warning with yaml_paths and continue' do
      config = described_class.new('invalid', content: <<~YML)
        yaml_paths: '*.my.yaml'
      YML

      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .to output(<<~MESSAGE).to_stderr
          \e[2K\e[33m`yaml_paths:` is deprecated\e[0m
          Replace with:
          \e[32mprecompile:
          - paths: "*.my.yaml"
            format: yaml
          \e[0m
        MESSAGE

      expect(config.precompile)
        .to eq([{ paths: '*.my.yaml', format: :yaml }])
    end

    it 'can print a deprecation warning with json_paths and continue' do
      config = described_class.new('invalid', content: <<~YML)
        json_paths: '*.my.json'
      YML

      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .to output(<<~MESSAGE).to_stderr
          \e[2K\e[33m`json_paths:` is deprecated\e[0m
          Replace with:
          \e[32mprecompile:
          - paths: "*.my.json"
            format: json
          \e[0m
        MESSAGE

      expect(config.precompile)
        .to eq([{ paths: '*.my.json', format: :json }])
    end

    it 'can print a deprecation warning with erb_paths and continue' do
      config = described_class.new('invalid', content: <<~YML)
        erb_paths: '*.my.erb'
      YML

      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .to output(<<~MESSAGE).to_stderr
          \e[2K\e[33m`erb_paths:` is deprecated\e[0m
          Replace with:
          \e[32mprecompile:
          - paths: "*.my.erb"
            format: erb
          \e[0m
        MESSAGE

      expect(config.precompile)
        .to eq([{ paths: '*.my.erb', format: :erb }])
    end

    it 'can print a deprecation warning with slim_paths and continue' do
      config = described_class.new('invalid', content: <<~YML)
        slim_paths: '*.my.slim'
      YML

      expect { ::Leftovers::Precompilers.build(config.precompile) }
        .to output(<<~MESSAGE).to_stderr
          \e[2K\e[33m`slim_paths:` is deprecated\e[0m
          Replace with:
          \e[32mprecompile:
          - paths: "*.my.slim"
            format: slim
          \e[0m
        MESSAGE

      expect(config.precompile)
        .to eq([{ paths: '*.my.slim', format: :slim }])
    end
  end
end
