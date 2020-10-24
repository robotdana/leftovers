# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::FileCollector do
  subject(:collector) do
    collector = described_class.new(ruby, file)
    collector.collect
    collector
  end

  before do
    Leftovers.reset
    Leftovers.config << Leftovers::Config.new('test', content: config)
  end

  after { Leftovers.reset }

  let(:config) { '' }
  let(:path) { 'foo.rb' }
  let(:file) { Leftovers::File.new(Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with affixxed methods' do
    let(:ruby) { 'test_html' }

    let(:config) do
      <<~YML
        rules:
          - name:
              has_suffix: '_html'
            calls:
              - itself: true
                delete_suffix: _html
              - value: html
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:test, :html, :test_html)) }
  end

  context 'with pluralize' do
    let(:ruby) { 'my_method(:value, :person)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: '*'
                transforms:
                  - pluralize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :values, :people)) }
  end

  context 'with singularize' do
    let(:ruby) { 'my_method(:values, :people)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: '*'
                transforms:
                  - singularize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :value, :person)) }
  end

  context 'with camelize' do
    let(:ruby) { 'my_method(:"kebab-case", :snake_case, :camelCase, :PascalCase)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: '*'
                camelize: true
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_method, :'Kebab-case', :SnakeCase, :CamelCase, :PascalCase))
    end
  end

  context 'with parameterize' do
    let(:ruby) { 'my_method(:"kebab-case", :snake_case, :camelCase, :PascalCase)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument: '*'
              parameterize: true
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_method, :'kebab-case', :snake_case, :camelcase, :pascalcase))
    end
  end

  context 'with underscore' do
    let(:ruby) { 'my_method(:"kebab-case", :snake_case, :camelCase, :PascalCase)' }

    let(:config) do
      <<~YML
        rules:
          name: my_method
          calls:
            - argument: '*'
              transforms:
                - underscore
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_method, :kebab_case, :snake_case, :camel_case, :pascal_case))
    end
  end

  context 'with titleize' do
    let(:ruby) { 'my_method(:value_id)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument: 1
              transforms:
                - titleize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Value)) }
  end

  context 'with demodulize' do
    let(:ruby) { 'my_method("Namespaced::Class", "MyClass")' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: '*'
                transforms: demodulize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Class, :MyClass)) }
  end

  context 'with deconstantize' do
    let(:ruby) { 'my_method("Namespaced::Class", "MyClass")' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: '*'
                deconstantize: true
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Namespaced)) }
  end

  context 'with upcase' do
    let(:ruby) { 'my_method("upcase")' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: 1
                transforms: [upcase]
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :UPCASE)) }
  end

  context 'with downcase' do
    let(:ruby) { 'my_method("DOWNCASE")' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: 1
                transforms: downcase
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :downcase)) }
  end

  context 'with swapcase' do
    let(:ruby) { 'my_method("swap_CASE")' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: 1
                transforms: swapcase
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :SWAP_case)) }
  end

  context 'with capitalize' do
    let(:ruby) { 'my_method("capitalize")' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: 1
                transforms: capitalize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Capitalize)) }
  end

  context 'with an activesupport modifier without activesupport' do
    before do
      cached_require = Leftovers.instance_variable_get(:@try_require)
      cached_require ||= Leftovers.instance_variable_set(:@try_require, {})
      allow(cached_require)
        .to receive(:key?).with('active_support/core_ext/string').and_return(true)
      allow(cached_require)
        .to receive(:[]).with('active_support/core_ext/string').and_return(false)
    end

    let(:ruby) { 'my_method(:value)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              - argument: 1
                transforms:
                  - camelize
      YML
    end

    it do
      message = <<~MESSAGE
        Tried creating a transformer using an activesupport method (camelize), but the activesupport gem was not available
        `gem install activesupport`
      MESSAGE

      expect { catch(:leftovers_exit) { subject } }
        .to output(a_string_ending_with(message)).to_stderr
    end
  end

  context 'with array values' do
    let(:ruby) { 'flow(whatever, [:method_1, :method_2])' }

    let(:config) do
      <<~YML
        rules:
          - name: flow
            calls:
              - argument: 2
                nested:
                  argument: '*'
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever, :method_1, :method_2)
    end
  end

  context 'with matches' do
    let(:ruby) { 'my_method(:whatever) && your_method(:whichever)' }

    let(:config) do
      <<~YML
        rules:
          - name:
              matches: "(my|your)_method"
            calls: 1
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_method, :your_method, :whatever, :whichever))
    end
  end

  context 'with match' do
    let(:ruby) { 'my_method(:whatever) && your_method(:whichever)' }

    let(:config) do
      <<~YML
        rules:
          - names:
              match: "(my|your)_method"
            calls: 1
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_method, :your_method, :whatever, :whichever))
    end
  end

  context 'with keyword argument with prefix' do
    let(:ruby) { 'my_method(whatever, some_values: :method, sum_values: :method2)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument:
                has_prefix: some
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :whatever, :method)) }
  end

  context 'with keyword argument with suffix' do
    let(:ruby) { 'my_method(whatever, some_values: :method, some_value: :method2)' }

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument:
                has_suffix: values
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :whatever, :method)) }
  end

  context 'with keyword argument with prefix and suffix' do
    let(:ruby) do
      <<~RUBY
        my_method(
          whatever,
          some_values: :method,
          sum_values: :method2,
          some_value: :method3
        )
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument:
                has_suffix: values
                has_prefix: some
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :whatever, :method)) }
  end

  context 'with shortcut keyword arguments' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        rules:
          name: my_method
          calls: kw
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :method)) }
  end

  context 'with shortcut position arguments' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        rules:
          name: my_method
          calls: 1
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :whatever)) }
  end

  context 'with shortcut keyword arguments defines' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        rules:
          name: my_method
          defines: kw
      YML
    end

    it { is_expected.to have_definitions(:method).and(have_calls(:my_method)) }
  end

  context 'with shortcut position arguments defines' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        rules:
          name: my_method
          defines: 1
      YML
    end

    it { is_expected.to have_definitions(:whatever).and(have_calls(:my_method)) }
  end

  context 'with csend arguments' do
    let(:ruby) { 'nil&.flow(:argument)' }

    let(:config) do
      <<~YML
        rules:
          - name: flow
            calls:
              argument: 1
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:flow, :argument)) }
  end

  context 'with position and keyword' do
    let(:ruby) do
      <<~RUBY
        my_method('value_1', 'value_2', my_keyword: 'value_3', my_other_keyword: 'value_4')
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument: [1, my_keyword]
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :value_1, :value_3)) }
  end

  context 'with position and keyword lvars' do
    let(:ruby) do
      <<~RUBY
        b = 1
        my_method(b, my_keyword: b)
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument: [1, my_keyword]
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method)) }
  end

  context 'with collect rest kwargs' do
    let(:ruby) do
      <<~RUBY
        args = {}
        my_method('my_value', my_keyword: 'my_keyword_value', **args)
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              argument: [1, my_keyword]
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_method, :my_value, :my_keyword_value))
    end
  end

  context 'with constant assignment values' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = %i{
          downcase
          upcase
        }
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: STRING_TRANSFORMS
            calls:
              argument: '*'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  end

  context 'with ivar assignment values' do
    let(:ruby) do
      <<~RUBY
        @string_transforms = %i{
          downcase
          upcase
        }
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: '@string_transforms'
            calls:
              argument: '*'
      YML
    end

    it { is_expected.to have_definitions(:@string_transforms).and(have_calls(:downcase, :upcase)) }
  end

  context 'with constant assignment values with freeze' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = %i{
          downcase
          upcase
        }.freeze
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: STRING_TRANSFORMS
            calls:
              argument: '*'
      YML
    end

    it do
      expect(subject).to have_definitions(:STRING_TRANSFORMS)
        .and(have_calls(:downcase, :upcase, :freeze))
    end
  end

  context 'with constant hash assignment keys' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = {
          downcase: true,
          upcase: true
        }
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: STRING_TRANSFORMS
            calls:
              keywords: true
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  end

  context 'with constant hash assignment keys with freeze' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = {
          downcase: true,
          upcase: true
        }.freeze
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: STRING_TRANSFORMS
            calls:
              keywords: true
      YML
    end

    it do
      expect(subject).to have_definitions(:STRING_TRANSFORMS)
        .and(have_calls(:downcase, :upcase, :freeze))
    end
  end

  context 'with nested hash assignment values' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = {
          body: { process: :downcase },
          title: { process: :upcase }
        }
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: STRING_TRANSFORMS
            calls:
              arguments: '**'
              nested:
                arguments: '**'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  end

  context 'with recursive hash assignment values' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = {
          body: { process: :downcase },
          title: { process: :upcase },
          properties: { each: { process: :swapcase } }
        }
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name: STRING_TRANSFORMS
            calls:
              - arguments: '**'
                recursive: true
      YML
    end

    it do
      expect(subject).to have_definitions(:STRING_TRANSFORMS)
        .and(have_calls(:downcase, :upcase, :swapcase))
    end
  end

  context 'with names unless names' do
    let(:ruby) do
      <<~RUBY
        my_magic_call(:my_method_one)
        non_magic_call(:my_method_two)
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name:
              has_suffix: _magic_call
            unless:
              name: non_magic_call
            calls: { arguments: 1 }
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_magic_call, :non_magic_call, :my_method_one))
    end
  end

  context 'with names unless names when the name is unless' do
    let(:ruby) do
      <<~RUBY
        my_magic_call(:my_method_one)
        non_magic_call(:my_method_two)
      RUBY
    end

    let(:config) do
      <<~YML
        rules:
          - name:
              has_suffix: _magic_call
              unless:
                - non_magic_call
            calls: { arguments: 1 }
      YML
    end

    it {
      expect(subject).to have_no_definitions
        .and(have_calls(:my_magic_call, :non_magic_call, :my_method_one))
    }
  end

  context 'with delete_after and delete_before on an empty string' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              arguments: 1
              delete_after: x
              delete_before: y
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method)) }
  end

  context 'with add_suffix argument with a suffix' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              arguments: 1
              add_suffix:
                argument: foo
                add_prefix: x
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method(:bar, foo: :baz)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :barxbaz)) }
  end

  context 'with add_suffix with a non string value without crashing' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              arguments: 1
              add_suffix:
                argument: foo
                add_prefix: x
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method(:bar, lol => :foo, foo: :baz)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :lol, :barxbaz)) }
  end

  context 'with has_argument with only value' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              value: foo
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 'qux')
        my_method('bar', kw: 'foo')
        my_method('lol', 'foo')
        my_method('beep')
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:bar, :lol, :my_method) }
  end

  context 'with has_argument with only value types' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              at: kw
              value:
                type: [String, Symbol, Integer, Float]
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 'qux')
        my_method('bar', kw: 1)
        my_method('lol', kw: no)
        my_method('foo', kw: 1.0)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :no, :baz, :foo, :my_method)) }
  end

  context 'with find has_argument with unless' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              value:
                type: [String, Symbol, Integer, Float]
              unless: kw
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', 'qux')
        my_method('bar', kw: 1)
        my_method('lol', kw: 1.0)
        my_method('foo', 1.0)
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:baz, :foo, :my_method) }
  end

  context 'with find has_argument with unless value' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              value:
                type: Integer
              unless:
                value: 0
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', 0)
        my_method('bar', 1, 0)
        my_method('lol', 1)
        my_method('foo')
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:lol, :my_method) }
  end

  context 'with find has_argument with only value type' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              at: kw
              value:
                type: String
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 'qux')
        my_method('bar', kw: 1)
        my_method('lol', kw: no)
        my_method('foo', kw: 1.0)
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:no, :baz, :my_method) }
  end

  context 'with find has_argument with only any of value' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              value: [foo, bar]
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 'bar')
        my_method('bar', kw: 'foo')
        my_method('lol', kw: 'qux')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :baz, :my_method)) }
  end

  context 'with find has_argument' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument: kw
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('bar', kw: 'foo')
        my_method('lol', 1 => true)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :my_method)) }
  end

  context 'with find has_argument with keyword param' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              at: kw
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('bar', kw: 'foo')
        my_method('lol', 1 => true)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :my_method)) }
  end

  context 'with find has_argument with keyword and value literal param' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              at: kw
              value: true
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('bar', kw: true)
        my_method('lol', kw: false)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :my_method)) }
  end

  context 'with find has_argument with string keys' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument: kw
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('bar', "kw" => 'foo')
        my_method('lol', 1 => true)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :my_method)) }
  end

  context 'with find has_argument with an index' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument: 2
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', 'foo', 'bar')
        my_method('bar', 'foo')
        my_method('lol')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :baz, :my_method)) }
  end

  context 'with find has_argument with an index and value' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              value: 'foo'
              at: 2
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', 'bar', 'foo')
        my_method('bar', 'foo')
        my_method('foo')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :my_method)) }
  end

  context 'with find has_argument with an index array and value' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              value: 'foo'
              at: [2,3]
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', 'bar', 'foo')
        my_method('bar', 'foo')
        my_method('foo')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :baz, :my_method)) }
  end

  context 'with find has_argument with a mix of kw and index array and value' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument:
              value: 'foo'
              at: [kw, 2]
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', 'bar', kw: 'foo')
        my_method('bar', 'foo')
        my_method('foo')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :baz, :my_method)) }
  end

  context 'with find has_argument with a mix of kw and index array acts like or' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            has_argument: [kw, 2]
            calls:
              arguments: 1
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', 'bar', kw: 'foo')
        my_method('bar', 'bar', 'foo')
        my_method('bit', kw: 'foo')
        my_method('lol', wk: 'foo')
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:baz, :bar, :bit, :my_method) }
  end

  context 'with add_prefix argument with an index' do
    let(:config) do
      <<~YML
        rules:
          - name: my_method
            calls:
              arguments: 1
              add_prefix:
                argument: 2
                add_suffix: '_'
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('bar', 'foo')
        my_method('lol')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:foo_bar, :lol, :my_method)) }
  end

  context 'with a method to define based on a method name' do
    let(:config) do
      <<~YML
        rules:
          - name: def_my_method
            defines:
              itself: true
              delete_prefix: def_
      YML
    end

    let(:ruby) do
      <<~RUBY
        def_my_method { |x| x.to_s }
      RUBY
    end

    it { is_expected.to have_definitions(:my_method).and(have_calls(:def_my_method, :to_s)) }
  end

  context 'with keep with string pattern args' do
    let(:config) do
      <<~YML
        keep:
          has_suffix: _id
      YML
    end

    let(:ruby) do
      <<~RUBY
        def this_id; end
        def that_id; end
        def this; end
      RUBY
    end

    it { is_expected.to have_definitions(:this).and(have_no_calls) }
  end
end
