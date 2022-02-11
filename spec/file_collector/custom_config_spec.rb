# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::FileCollector do
  subject(:collector) do
    collector = described_class.new(ruby, file)
    collector.collect
    collector
  end

  before do
    allow(Leftovers).to receive(:try_require_cache).and_call_original
    allow(Leftovers).to receive(:try_require_cache).with('bundler').and_return(false)

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
        dynamic:
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

  context 'with dynamic comment' do
    let(:ruby) { '[:This, :That] # leftovers:dynamic:call_each' }

    let(:config) do
      <<~YML
        dynamic:
          - name: call_each
            calls:
              argument: '*'
              add_suffix: Class
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:ThisClass, :ThatClass)) }

    context 'when across multiple lines' do
      let(:ruby) do
        <<~RUBY
          [ # leftovers:dynamic:call_each
            :This,
            :That
          ]
        RUBY
      end

      it { is_expected.to have_no_definitions.and(have_calls(:ThisClass, :ThatClass)) }
    end
  end

  context 'with pluralize' do
    let(:ruby) { 'my_method(:value, :person, [])' }

    let(:config) do
      <<~YML
        requires:
          - 'active_support'
          - 'active_support/core_ext/string'
        dynamic:
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
    let(:ruby) { 'my_method(:values, :people, [])' }

    let(:config) do
      <<~YML
        requires:
          - 'active_support'
          - 'active_support/core_ext/string'
        dynamic:
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
    let(:ruby) { 'my_method(:"kebab-case", :snake_case, :camelCase, :PascalCase, [])' }

    let(:config) do
      <<~YML
        requires:
          - 'active_support'
          - 'active_support/core_ext/string'
        dynamic:
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
    let(:ruby) { 'my_method(:"kebab-case", :snake_case, :camelCase, :PascalCase, [])' }

    let(:config) do
      <<~YML
        requires:
          - 'active_support'
          - 'active_support/core_ext/string'
        dynamic:
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
    let(:ruby) { 'my_method(:"kebab-case", :snake_case, :camelCase, :PascalCase, [])' }

    let(:config) do
      <<~YML
        requires:
          - 'active_support'
          - 'active_support/core_ext/string'
        dynamic:
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
    let(:ruby) { 'my_method(:value_id, [])' }

    let(:config) do
      <<~YML
        require:
          - 'active_support'
          - active_support/core_ext/string
        dynamic:
          - name: my_method
            calls:
              argument: '*'
              transforms:
                - titleize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Value)) }
  end

  context 'with demodulize' do
    let(:ruby) { 'my_method("Namespaced::Class", "MyClass", [])' }

    let(:config) do
      <<~YML
        requires:
          - 'active_support'
          - 'active_support/core_ext/string'
        dynamic:
          - name: my_method
            calls:
              - argument: '*'
                transforms: demodulize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Class, :MyClass)) }
  end

  context 'with deconstantize' do
    let(:ruby) { 'my_method("Namespaced::Class", "MyClass", [])' }

    let(:config) do
      <<~YML
        requires:
          - 'active_support'
          - 'active_support/core_ext/string'
        dynamic:
          - name: my_method
            calls:
              - argument: '*'
                deconstantize: 'true'
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Namespaced)) }
  end

  context 'with upcase' do
    let(:ruby) { 'my_method("upcase", [])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              - argument: '*'
                transforms: [upcase]
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :UPCASE)) }
  end

  context 'with downcase' do
    let(:ruby) { 'my_method("DOWNCASE", [])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              - argument: '*'
                transforms: downcase
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :downcase)) }
  end

  context 'with swapcase' do
    let(:ruby) { 'my_method(:swap, "CASE", [])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              - argument: '*'
                transforms: swapcase
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :SWAP, :case)) }
  end

  context 'with capitalize' do
    let(:ruby) { 'my_method(:capitalize, [])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              - argument: '*'
                transforms: capitalize
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :Capitalize)) }
  end

  context 'with an activesupport modifier without activesupport required' do
    %i{
      camelize
      deconstantize
      demodulize
      parameterize
      pluralize
      singularize
      titleize
      underscore
    }.each do |method|
      context "for #{method}" do
        before do
          allow_any_instance_of(::String).to receive(method).and_raise(::NoMethodError) # rubocop:disable RSpec/AnyInstance # not sure how else i'd solve this
        end

        let(:ruby) { 'my_method(:value)' }

        let(:config) do
          <<~YML
            dynamic:
              - name: my_method
                calls:
                  - argument: 0
                    transforms:
                      - #{method}
          YML
        end

        it do
          message = <<~MESSAGE
            Tried using the String##{method} method, but the activesupport gem was not available and/or not required
            `gem install activesupport`, and/or add `requires: ['active_support', 'active_support/core_ext/string']` to your .leftovers.yml
          MESSAGE

          expect { catch(:leftovers_exit) { subject } }
            .to output(a_string_ending_with(message)).to_stderr
        end
      end
    end
  end

  context 'with array values' do
    let(:ruby) { 'flow(whatever, [:method_1, :method_2])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: 1
                nested:
                  argument: '*'
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever, :method_1, :method_2)
    end
  end

  context 'with nested with specific position' do
    let(:ruby) { 'flow(whatever, [:method_1, :method_2])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: 1
                nested:
                  argument: 1
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever, :method_2)
    end
  end

  context 'with nested with specific, missing position' do
    let(:ruby) { 'flow(whatever, [:method_1, :method_2])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: 1
                nested:
                  argument: 2
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever)
    end
  end

  context 'with nested with specific, missing keyword' do
    let(:ruby) { 'flow(whatever, {a: :method_1, b: :method_2})' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: 1
                nested:
                  argument: c
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever)
    end
  end

  context 'with nested with specific, non-string-symbol position' do
    let(:ruby) { 'flow(whatever, [:method_1, nil])' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: 1
                nested:
                  argument: 1
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever)
    end
  end

  context 'with nested with specific, non-string-symbol keyword' do
    let(:ruby) { 'flow(whatever, {a: :method_1, kw: nil})' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: 1
                nested:
                  argument: kw
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever)
    end
  end

  context 'with nested with non-string-symbol position' do
    let(:ruby) { 'flow(whatever, nil)' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: 1
                nested:
                  argument: 1
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever)
    end
  end

  context 'with nested with non-string-symbol keyword' do
    let(:ruby) { 'flow(whatever, kw: nil)' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              - argument: kw
                nested:
                  argument: 1
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:flow, :whatever)
    end
  end

  context 'with matches' do
    let(:ruby) { 'my_method(:whatever) && your_method(:whichever)' }

    let(:config) do
      <<~YML
        dynamic:
          - name:
              matches: "(my|your)_method"
            calls: 0
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
        dynamic:
          - names:
              match: "(my|your)_method"
            calls: 0
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
        dynamic:
          - name: my_method
            calls:
              argument:
                has_prefix: some
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :whatever, :method)) }
  end

  context 'with name with any of multiple prefixes' do
    let(:ruby) { 'my_method(:whatever) && your_method(:whichever) && their_method(:whenever)' }

    let(:config) do
      <<~YML
        dynamic:
          name:
            - has_prefix: my
            - has_prefix: your
          calls: 0
      YML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:my_method, :your_method, :whatever, :whichever, :their_method))
    end
  end

  context 'with keyword argument with suffix' do
    let(:ruby) { 'my_method(whatever, some_values: :method, some_value: :method2)' }

    let(:config) do
      <<~YML
        dynamic:
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
        dynamic:
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
        dynamic:
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
        dynamic:
          name: my_method
          calls: 0
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :whatever)) }
  end

  context 'with shortcut keyword arguments defines' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        dynamic:
          name: my_method
          defines: kw
      YML
    end

    it { is_expected.to have_definitions(:method).and(have_calls(:my_method)) }
  end

  context 'with defines matching keep' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        keep: method
        dynamic:
          name: my_method
          defines: kw
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method)) }
  end

  context 'with defines matching keep in transform set' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        keep: method
        dynamic:
          name: my_method
          defines:
            argument: kw
            transforms:
              - original
              - add_suffix: '='
      YML
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method)) }
  end

  context 'with defines matching test_only sometimes' do
    let(:ruby) { 'my_method(:whatever, :method)' }

    let(:config) do
      <<~YML
        test_only: method
        dynamic:
          name: my_method
          defines: '*'
      YML
    end

    it do
      expect(subject).to have_non_test_definitions(:whatever)
        .and(have_test_only_definitions(:method))
        .and(have_calls(:my_method))
    end
  end

  context 'with defines matching test_only' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        test_only: method
        dynamic:
          name: my_method
          defines: kw
      YML
    end

    it do
      expect(subject).to have_no_non_test_definitions
        .and(have_test_only_definitions(:method))
        .and(have_calls(:my_method))
    end
  end

  context 'with defines matching test_only in transform set' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        test_only: method
        dynamic:
          name: my_method
          defines:
            argument: kw
            transforms:
              - original
              - add_suffix: '='
      YML
    end

    it do
      expect(subject).to have_no_non_test_definitions
        .and(have_test_only_definitions(:method, :method=))
        .and(have_calls(:my_method))
    end
  end

  context 'with defines with transform set with an empty value' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        keep: method
        dynamic:
          name: my_method
          defines:
            argument: kw
            transforms:
              - delete_prefix: meth
              - delete_suffix: method
      YML
    end

    it { is_expected.to have_definitions(:od).and(have_calls(:my_method)) }
  end

  context 'with shortcut position arguments defines' do
    let(:ruby) { 'my_method(:whatever, kw: :method)' }

    let(:config) do
      <<~YML
        dynamic:
          name: my_method
          defines: 0
      YML
    end

    it { is_expected.to have_definitions(:whatever).and(have_calls(:my_method)) }
  end

  context 'with csend arguments' do
    let(:ruby) { 'nil&.flow(:argument)' }

    let(:config) do
      <<~YML
        dynamic:
          - name: flow
            calls:
              argument: 0
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
        dynamic:
          - name: my_method
            calls:
              argument: [0, my_keyword]
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
        dynamic:
          - name: my_method
            calls:
              argument: [0, my_keyword]
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
        dynamic:
          - name: my_method
            calls:
              argument: [0, my_keyword]
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
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              argument: '*'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  end

  context "with constant assignment to something we can't process when frozen" do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = /a_regex/.freeze
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              argument: '*'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:freeze)) }
  end

  context "with defines constant assignment to something we can't process when frozen" do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = /a_regex/.freeze
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            defines:
              argument: '*'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:freeze)) }
  end

  context 'with defines constant assignment to an empty string' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = ''
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            defines:
              argument: '*'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_no_calls) }
  end

  context "with constant assignment to something we can't process" do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = /a_regex/
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              argument: '*'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_no_calls) }
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
        dynamic:
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
        dynamic:
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
        rest = {}
        STRING_TRANSFORMS = {
          downcase: true,
          upcase: true,
          1 => true,
          **rest
        }
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              keywords: '**'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  end

  context 'with constant specific hash assignment keys' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = {
          downcase: true,
          upcase: true,
          1 => true
        }
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              keywords: [downcase, upcase]
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  end

  context 'with constant hash assignment keys with has_suffix' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = {
          downcase: true,
          upcase: true,
          other: true,
          1 => true
        }
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              keywords:
                has_suffix: case
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  end

  context 'with constant hash assignment keys but with an array assigned' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = [
          :downcase,
          :upcase
        ]
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              keywords: '**'
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_no_calls) }
  end

  context 'with constant hash assignment keys with has_suffix but with an array assigned' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = [
          :downcase,
          :upcase,
          :other
        ]
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              keywords:
                has_suffix: case
      YML
    end

    it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_no_calls) }
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
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              keywords: '**'
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
        rest = {}
        STRING_TRANSFORMS = {
          body: { process: :downcase },
          title: { process: :upcase },
          **rest
        }
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
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
          properties: { each: { process: :swapcase }, then: { process: nil }, and_then: nil, finally: { nil => nil }}
        }
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              - arguments: '**'
                recursive: 'true'
      YML
    end

    it do
      expect(subject).to have_definitions(:STRING_TRANSFORMS)
        .and(have_calls(:downcase, :upcase, :swapcase))
    end
  end

  context 'with recursive hash assignment values and keywords' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = {
          body: { process: :downcase },
          title: { process: :upcase },
          properties: {
            each: { process: :swapcase }, then: { process: nil }, and: nil, finally: { nil => nil }
          }
        }
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              - arguments: '**'
                keywords: '**'
                recursive: true
      YML
    end

    it do
      expect(subject).to have_definitions(:STRING_TRANSFORMS)
        .and(have_calls(
          :downcase, :upcase, :swapcase,
          :body, :title, :properties, :each, :then, :and, :finally, :process
        ))
    end
  end

  context 'with recursive hash assignment values and keywords and array' do
    let(:ruby) do
      <<~RUBY
        STRING_TRANSFORMS = [{
          body: { process: :downcase },
          title: { process: :upcase },
          properties: [{ process: :swapcase }, { process: [nil] }, nil, { nil => nil }]
        }]
      RUBY
    end

    let(:config) do
      <<~YML
        dynamic:
          - name: STRING_TRANSFORMS
            calls:
              - arguments: ['**', '*']
                keywords: '**'
                recursive: true
      YML
    end

    it do
      expect(subject).to have_definitions(:STRING_TRANSFORMS)
        .and(have_calls(:downcase, :upcase, :swapcase, :body, :title, :properties, :process))
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
        dynamic:
          - name:
              has_suffix: _magic_call
            unless:
              name: non_magic_call
            calls: { arguments: 0 }
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
        dynamic:
          - name:
              has_suffix: _magic_call
              unless:
                - non_magic_call
            calls: { arguments: 0 }
      YML
    end

    it {
      expect(subject).to have_no_definitions
        .and(have_calls(:my_magic_call, :non_magic_call, :my_method_one))
    }
  end

  context 'with delete_after and delete_before on an empty string and nil' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: '*'
              transforms:
                - delete_after: x
                - delete_before: x
                - delete_prefix: x
                - delete_suffix: x
                - split: x
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('x', '', nil)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method)) }
  end

  context 'with add_suffix argument with a suffix' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
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

  context 'with add_suffix argument with a non-string suffix' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
              add_suffix:
                argument: foo
                add_prefix: x
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method(:bar, foo: baz)
      RUBY
    end

    # no bar, barx, or barxbaz
    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :baz)) }
  end

  context 'with add_suffix position argument' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
              add_suffix:
                argument: 1
                add_prefix: x
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method(:bar, :baz)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :barxbaz)) }
  end

  context 'with add_suffix position argument with no value to suffix' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
              add_suffix:
                argument: 1
                add_prefix: x
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method(bar, :baz)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :bar)) }
  end

  context 'with add_suffix position arguments' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
              add_suffix:
                arguments: [1,2]
                add_prefix: x
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method(:bar, :baz, :foo)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:my_method, :barxbaz, :barxfoo)) }
  end

  context 'with add_suffix with a non string value without crashing' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument:
              has_value: foo
            calls:
              arguments: 0
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

  context 'with has_argument with keyword, position, and value' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: [kw, 1]
              has_value: foo
            calls:
              arguments: 0
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

  context 'with has_argument with String type' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: String
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: 'qux')
        my_method('no', kw: 1)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:yes, :my_method)) }
  end

  context 'with has_argument with Symbol type' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: Symbol
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: :qux)
        my_method('no', kw: 'qux')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:yes, :my_method)) }
  end

  context 'with has_argument with Proc type' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: Proc
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: -> {})
        my_method('yes2', kw: proc {})
        my_method('yes3', kw: lambda {})
        my_method('no', kw: Proc.new {}) # not a "literal"
        my_method('no', kw: thing {})
      RUBY
    end

    it do
      expect(subject)
        .to have_no_definitions
        .and(have_calls(:yes, :yes2, :yes3, :proc, :lambda, :Proc, :new, :my_method, :thing))
    end
  end

  context 'with has_argument with Integer type' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: Integer
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: 1)
        my_method('no', kw: 1.0)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:yes, :my_method)) }
  end

  context 'with has_argument with Float type' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: Float
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: 1.0)
        my_method('no', kw: 1)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:yes, :my_method)) }
  end

  context 'with has_argument with Array type' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: Array
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: [])
        my_method('no', kw: {})
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:yes, :my_method)) }
  end

  context 'with has_argument with Hash type' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: Hash
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: {})
        my_method('no', kw: [])
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:yes, :my_method)) }
  end

  context 'with has_argument with multiple types' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: [Hash, String]
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('yes', kw: {})
        my_method('yes2', kw: 'thing')
        my_method('no', kw: 3)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:yes, :yes2, :my_method)) }
  end

  context 'with find has_argument with unless' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              has_value:
                type: [String, Symbol, Integer, Float]
              unless: kw
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument:
              has_value:
                type: Integer
              unless:
                has_value: 0
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value:
                type: String
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 'qux')
        my_method('bar', kw: 1)
        my_method('lol', kw: another_method)
        my_method('foo', kw: 1.0)
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:another_method, :baz, :my_method) }
  end

  context 'with find has_argument with only value type at any kw' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: '**'
              has_value:
                type: String
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 'qux')
        my_method('bar', other_kw: '1')
        my_method('lol', 'position')
        my_method('foo', kw: :no)
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:bar, :baz, :my_method) }
  end

  context 'with find has_argument with only value type at any position' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: '*'
              has_value:
                type: Integer
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 1)
        my_method('bar', '1', kw: 1)
        my_method('lol', 1)
        my_method('foo', 'no', 1)
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:lol, :foo, :my_method) }
  end

  context 'with find has_argument with any positional argument' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: '*'
            calls:
              arguments: kw
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('baz', kw: 'kw1')
        my_method(kw: 'kw2')
      RUBY
    end

    it { is_expected.to have_no_definitions.and have_calls(:kw1, :my_method) }
  end

  context 'with find has_argument with only any of value' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              has_value: [foo, bar]
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument: kw
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument:
              at: kw
            calls:
              arguments: 0
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

  context 'with find has_argument with has_value name matcher' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              has_value:
                has_prefix: 'A'
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('bar', 'A1')
        my_method('lol', '1A')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :my_method)) }
  end

  context 'with find has_argument with keyword and value literal param' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: kw
              has_value: true
            calls:
              arguments: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method('bar', kw: true)
        my_method('lol', kw: false)
        my_method('no', kw: {})
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:bar, :my_method)) }
  end

  context 'with find has_argument with string keys' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument: kw
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument: 1
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument:
              has_value: 'foo'
              at: 1
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument:
              has_value: 'foo'
              at: [1,2]
            calls:
              arguments: 0
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

  context 'with find has_argument with an index array' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument: [1,2]
            calls:
              arguments: 0
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

  context 'with find has_argument with an index array at at' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            has_argument:
              at: [1,2]
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument:
              has_value: 'foo'
              at: [kw, 1]
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            has_argument: [kw, 1]
            calls:
              arguments: 0
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
        dynamic:
          - name: my_method
            calls:
              arguments: 0
              add_prefix:
                argument: 1
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

  context 'with add_prefix argument with an index when the value is not a symbol' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
              add_prefix: 'call_'
      YML
    end

    let(:ruby) do
      <<~RUBY
        lol = 1 # force lol to be a local variable
        my_method(:foo)
        my_method('bar')
        my_method(baz())
        my_method(lol)
      RUBY
    end

    it do
      expect(subject).to have_no_definitions.and(have_calls(:call_foo, :call_bar, :baz, :my_method))
    end
  end

  context 'with add_prefix argument with nothing to prefix' do
    let(:config) do
      <<~YML
        dynamic:
          - name: my_method
            calls:
              arguments: 0
              add_prefix:
                argument: 1
                add_suffix: '_'
      YML
    end

    let(:ruby) do
      <<~RUBY
        my_method({}, 'foo')
        my_method('lol')
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:lol, :my_method)) }
  end

  context 'with a method to define based on a method name' do
    let(:config) do
      <<~YML
        dynamic:
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

  context 'with has_receiver' do
    let(:config) do
      <<~YML
        dynamic:
          name: new
          has_receiver: Caller
          calls:
            argument: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        Caller.new(:yes)
        NotCaller.new(:no)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:Caller, :new, :yes, :NotCaller)) }
  end

  context 'with has_receiver list' do
    let(:config) do
      <<~YML
        dynamic:
          name: new
          has_receiver:
            - Caller
            - Logger
          calls:
            argument: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        Caller.new(:yes)
        Logger.new(:yes2)
        NotCaller.new(:no)
      RUBY
    end

    it do
      expect(subject)
        .to have_no_definitions
        .and(have_calls(:Caller, :Logger, :yes2, :new, :yes, :NotCaller))
    end
  end

  context 'with recursive has_receiver' do
    let(:config) do
      <<~YML
        dynamic:
          name: new
          has_receiver:
            match: Caller
            has_receiver: Leftovers
          calls:
            argument: 0
      YML
    end

    let(:ruby) do
      <<~RUBY
        Leftovers::Caller.new(:yes)
        Caller.new(:no)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:Caller, :Leftovers, :new, :yes)) }
  end

  context 'with values from yaml document' do
    let(:config) do
      <<~YML
        dynamic:
          document: true
          calls:
            argument: name
      YML
    end

    let(:path) { 'foo.yml' }

    let(:yaml) do
      <<~YML
        name: MyClassName
      YML
    end

    let(:ruby) { ::Leftovers::YAML.precompile(yaml, file) }

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:__leftovers_document, :MyClassName))
    end
  end
end
