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

  context 'with matched keyword arguments' do
    let(:ruby) { 'my_method(whatever, some_values: :method)' }

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
              keys: true
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
              keys: true
      YML
    end

    it do
      expect(subject).to have_definitions(:STRING_TRANSFORMS)
        .and(have_calls(:downcase, :upcase, :freeze))
    end
  end

  # context 'with nested hash assignment values' do
  #   let(:ruby) do
  #     <<~RUBY
  #       STRING_TRANSFORMS = {
  #         body: { process: :downcase },
  #         title: { process: :upcase }
  #       }
  #     RUBY
  #   end

  #   let(:config) do
  #     <<~YML
  #       rules:
  #         - name: STRING_TRANSFORMS
  #           calls:
  #             arguments: '**'
  #     YML
  #   end

  #   it { is_expected.to have_definitions(:STRING_TRANSFORMS).and(have_calls(:downcase, :upcase)) }
  # end

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
end
