# frozen_string_literal: true

RSpec.describe Leftovers::Config do
  before { Leftovers.reset }

  describe '.dynamic' do
    describe 'gems' do
      files = Pathname.glob("#{__dir__}/../lib/config/*.yml")
      gems = files.map { |f| f.basename.sub_ext('').to_s }

      gems.each do |gem|
        it "can load #{gem} default config" do
          config = described_class.new(gem)
          expect { catch(:leftovers_exit) { config.dynamic } }.not_to raise_error
        end
      end
    end

    it 'can report config parse errors' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name: my_method
            - calls:
            arguments: 1
      YML
      expect { catch(:leftovers_exit) { config.dynamic } }.to output(
        "\e[31mConfig SyntaxError: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "did not find expected key while parsing a block mapping at line 2 column 5\e[0m\n"
      ).to_stderr
    end

    it 'can report errors with transform dynamic affix dynamic' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name: my_method
            calls:
              arguments: 1
              add_prefix:
                is_argument: foo
                joiner: baz
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      unless Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7') # || defined?(::DidYouMean)
        allow(::Leftovers::ConfigValidator::ErrorProcessor)
          .to receive(:did_you_mean).with('joiner', be_a(Array))
          .and_return([])
        allow(::Leftovers::ConfigValidator::ErrorProcessor)
          .to receive(:did_you_mean).with('is_argument', be_a(Array))
          .and_return(['argument'])
      end

      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/calls/add_prefix: invalid property keyword: joiner
          Valid keywords: argument, arguments, keyword, keywords, itself, value, nested, recursive, transforms, pluralize, singularize, camelize, camelcase, underscore, titleize, titlecase, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, and delete_after\e[0m
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/calls/add_prefix: invalid property keyword: is_argument
          Valid keywords: argument, arguments, keyword, keywords, itself, value, nested, recursive, transforms, pluralize, singularize, camelize, camelcase, underscore, titleize, titlecase, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, and delete_after
          Did you mean? argument\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines/delete_prefix: must be a string (was an object)\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines/transforms: invalid property keyword: infix
          Valid keywords: original, pluralize, singularize, camelize, camelcase, underscore, titleize, titlecase, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, and delete_after\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines/transforms/0: can't be: add_prefix
          Valid values: original, pluralize, singularize, camelize, camelcase, underscore, titleize, titlecase, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, or swapcase\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      unless Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7') # || defined?(::DidYouMean)
        allow(::Leftovers::ConfigValidator::ErrorProcessor)
          .to receive(:did_you_mean).with('origin', be_a(Array))
          .and_return(['original'])
      end
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines/transforms/0: can't be: origin
          Valid values: original, pluralize, singularize, camelize, camelcase, underscore, titleize, titlecase, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, or swapcase
          Did you mean? original\e[0m
        MESSAGE
    end

    it 'can report errors when using name and names' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names: my_other_method
            name: my_method
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0: use only one of: name or names\e[0m
        MESSAGE
    end

    it 'can report errors when using path and paths' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names: my_method
            path: ./app
            paths: ./lib
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0: use only one of: path or paths\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0: use only one of: call or calls\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0: use only one of: define or defines\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0: use only one of: call or calls\e[0m
          \e[31mConfig SchemaError: (#{path}): /dynamic/0: use only one of: define or defines\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)

      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0: invalid property keyword: tuesday
          Valid keywords: name, names, path, paths, document, has_argument, has_arguments, has_receiver, unless, call, calls, define, and defines\e[0m
        MESSAGE
    end

    it 'can report errors when using invalid argument values' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            calls:
              argument: true
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/calls/argument is invalid\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines: use only one of: argument or arguments\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines: use only one of: keyword or keywords\e[0m
        MESSAGE
    end

    it 'can report errors when using missing argument etc' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines:
              add_suffix: foo
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines: requires at least one of these keywords: argument, arguments, keyword, keywords, itself, or value\e[0m
        MESSAGE
    end

    it 'can report errors when using nonexistent keys for calls' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            calls:
              param: foo
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/calls: invalid property keyword: param
          Valid keywords: argument, arguments, keyword, keywords, itself, value, nested, recursive, transforms, pluralize, singularize, camelize, camelcase, underscore, titleize, titlecase, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, and delete_after\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/defines: invalid property keyword: param
          Valid keywords: argument, arguments, keyword, keywords, itself, value, nested, recursive, transforms, pluralize, singularize, camelize, camelcase, underscore, titleize, titlecase, demodulize, deconstantize, parameterize, downcase, upcase, capitalize, swapcase, add_prefix, add_suffix, split, delete_prefix, delete_suffix, delete_before, and delete_after\e[0m
        MESSAGE
    end

    it 'can report errors when using nonexistent keys for name' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names:
              starts_with: my_method
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0/names: invalid property keyword: starts_with
          Valid keywords: match, matches, has_prefix, has_suffix, and unless\e[0m
        MESSAGE
    end

    it 'can report errors when using invalid vales for name' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names: 1.0
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0/names is invalid\e[0m
        MESSAGE
    end

    it 'can report errors when using invalid value number for has prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: 1.0
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0/has_prefix: must be a string (was a number)\e[0m
        MESSAGE
    end

    it 'can report errors when using invalid value integer for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: 1
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0/has_prefix: must be a string (was an integer)\e[0m
        MESSAGE
    end

    it 'can report errors when using invalid value array for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: []
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0/has_prefix: must be a string (was an array)\e[0m
        MESSAGE
    end

    it 'can report errors for empty keep' do
      config = described_class.new('invalid', content: <<~YML)
        keep: []
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep: can't be empty\e[0m
        MESSAGE
    end

    it 'can report errors for empty keep object' do
      config = described_class.new('invalid', content: <<~YML)
        keep: {}
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep: can't be empty\e[0m
        MESSAGE
    end

    it 'can report errors for empty keep string' do
      config = described_class.new('invalid', content: <<~YML)
        keep: ''
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep: can't be empty\e[0m
        MESSAGE
    end

    it 'can report errors when using invalid value true for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: true
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0/has_prefix: must be a string (was a boolean)\e[0m
        MESSAGE
    end

    it 'can report errors when using invalid value null for has_prefix' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - has_prefix: null
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /keep/0/has_prefix: must be a string (was a null)\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/has_argument/has_value/0 is invalid\e[0m
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
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(<<~MESSAGE).to_stderr
          \e[31mConfig SchemaError: (#{path}): /dynamic/0/has_argument/has_value/type is invalid\e[0m
        MESSAGE
    end
  end
end
