# frozen_string_literal: true

RSpec.describe Leftovers::Config do
  describe '.rules' do
    describe 'gems' do
      files = Pathname.glob("#{__dir__}/../lib/config/*.yml")
      gems = files.map { |f| f.basename.sub_ext('').to_s }

      gems.each do |gem|
        it "can load #{gem} default config" do
          config = described_class.new(gem)
          expect { catch(:leftovers_exit) { config.rules } }.not_to raise_error
        end
      end
    end

    it 'can report config parse errors' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - name: my_method
            - calls:
            arguments: 1
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig SyntaxError: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "did not find expected key while parsing a block mapping at line 2 column 5\e[0m\n"
      ).to_stderr
    end

    it 'can report errors with transform dynamic affix rules' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - name: my_method
            calls:
              arguments: 1
              add_prefix:
                get_the_keyword: foo
                joiner: baz
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "invalid transform value argument (add_prefix: { get_the_keyword: foo }).\n" \
        "Valid keys are from_argument, joiner\n" \
        " for calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors with transform dynamic rules' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - name: my_method
            defines:
              arguments: 1
              delete_prefix:
                from_argument: foo
                joiner: baz
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        'invalid transform value (delete_prefix: {:from_argument=>"foo", :joiner=>"baz"}).' \
        "\nHash values are only valid for add_prefix, add_suffix\n" \
        " for defines for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors with transform keys' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - name:
            - my_method
            - my_other_method
            defines:
              arguments: 1
              transforms:
                infix: how
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        'invalid transform key: (infix: how)' \
        "\nValid transform keys are original, delete_before, delete_after, add_prefix, " \
        'add_suffix, delete_prefix, delete_suffix, replace_with, downcase, upcase, capitalize, ' \
        'swapcase, pluralize, singularize, camelize, camelcase, underscore, titleize, ' \
        "titlecase, demodulize, deconstantize, parameterize\n" \
        " for defines for my_method, my_other_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using name and names' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - name: my_method
            skip: true
            names: my_other_method
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Only use one of name/names for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using path and paths' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            path: ./app
            skip: true
            paths: ./lib
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Only use one of path/paths for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using call and calls' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            calls:
              argument: 1
            call:
              argument: 2
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Only use one of call/calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using define and defines' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            defines:
              argument: 1
            define:
              argument: 2
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Only use one of define/defines for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using skip with define' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            skip: true
            define:
              argument: 1
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "skip can't exist with defines or calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using skip with defines' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            skip: true
            defines:
              argument: 1
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "skip can't exist with defines or calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using skip with call' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            skip: true
            call:
              argument: 1
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "skip can't exist with defines or calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using skip with calls' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            skip: true
            calls:
              argument: 1
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "skip can't exist with defines or calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using invalid conditions' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            calls:
              argument: 1
              if:
                tuesday: true
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Invalid condition {:tuesday=>true}. Valid condition keys are: has_argument\n" \
        " for calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using invalid argument values' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            calls:
              argument: true
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        'Invalid value for argument: true. ' \
        "Must by a string ('*', '**', or a keyword), or a hash with the name match rules, "\
        "or an integer, or an array of these\n" \
        " for calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using argument and arguments' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            defines:
              argument: 1
              arguments: kw
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Only use one of argument/arguments for defines for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using key and keys' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            defines:
              key: true
              keys: true
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Only use one of key/keys for defines for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using linked_transforms and transforms' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            defines:
              argument: 1
              linked_transforms:
                - original
              transforms:
                - add_suffix
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "Only use one of linked_transforms/transforms for defines for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using missing argument etc' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            defines:
              add_suffix: foo
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "require at least one of 'argument(s)', 'key(s)', itself for defines for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using nonexistent keys for calls' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            calls:
              param: foo
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "unknown keyword: param for calls for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using nonexistent keys for defines' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: my_method
            defines:
              param: foo
              keyword: bar
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "unknown keywords: param, keyword for defines for my_method\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using nonexistent keys for name' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names:
              starts_with: my_method
            skip: true
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        'Invalid value for name {:starts_with=>"my_method"}, ' \
        "valid keys are matches, has_prefix, has_suffix for [:starts_with, \"my_method\"]\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using invalid vales for name' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: 1.0
            skip: true
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        'Invalid value type for name 1.0, valid types are a String, '\
        "or an object with keys matches, has_prefix, has_suffix for 1.0\e[0m\n"
      ).to_stderr
    end

    it 'can report errors when using invalid vales for value' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - names: fancy
            calls:
              argument: 1
              if:
                has_argument:
                  value:
                    class: String
      YML
      expect { catch(:leftovers_exit) { config.rules } }.to output(
        "\e[31mConfig Error: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "invalid value {:class=>\"String\"} for calls for fancy\e[0m\n"
      ).to_stderr
    end
  end
end
