# frozen_string_literal: true

RSpec.describe Leftovers::Config do
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
                get_the_keyword: foo
                joiner: baz
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
    end

    it 'can report errors with transform dynamic dynamic' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - name: my_method
            defines:
              arguments: 1
              delete_prefix:
                from_argument: foo
                joiner: baz
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
    end

    it 'can report errors when using name and names' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - name: my_method
            names: my_other_method
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
    end

    it 'can report errors when using keyword and keywords' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: my_method
            defines:
              keyword: true
              keywords: true
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
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
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
    end

    it 'can report errors when using nonexistent keys for name' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names:
              starts_with: my_method
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
    end

    it 'can report errors when using invalid vales for name' do
      config = described_class.new('invalid', content: <<~YML)
        keep:
          - names: 1.0
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
    end

    it 'can report errors when using invalid vales for value' do
      config = described_class.new('invalid', content: <<~YML)
        dynamic:
          - names: fancy
            has_argument:
              value:
                class: String
            calls:
              argument: 1
      YML
      path = ::File.expand_path('../lib/config/invalid.yml', __dir__)
      expect { catch(:leftovers_exit) { config.dynamic } }
        .to output(a_string_starting_with("\e[31mConfig SchemaError: (#{path}): ")).to_stderr
    end
  end
end
