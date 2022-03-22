# frozen_string_literal: true

require 'spec_helper'

::RSpec.describe ::Leftovers::FileCollector do
  subject(:collector) do
    collector = described_class.new(ruby, file)
    collector.collect
    collector
  end

  let(:path) { 'foo.rb' }
  let(:file) { ::Leftovers::File.new(::Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with inline comment allows' do
    let(:ruby) do
      <<~RUBY
        def method_name # leftovers:allow
        end

        def method_name=(value) # leftovers:allows
        end

        def method_name? # leftovers:allowed
        end

        def method_name! # leftovers:skip
        end
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_no_calls) }
  end

  context 'with inline comment test' do
    let(:ruby) do
      <<~RUBY
        def method_name # leftovers:for_test
        end

        def method_name=(value) # leftovers:for_tests
        end

        def method_name? # leftovers:testing
        end

        def method_name! # leftovers:test
        end
      RUBY
    end

    it 'has only test definitions' do
      expect(collector).to have_no_calls
        .and have_no_non_test_definitions
        .and have_test_only_definitions(:method_name, :method_name?, :method_name=, :method_name!)
    end
  end

  context 'with inline comment calls' do
    let(:ruby) do
      <<~RUBY
        def method_name # leftovers:call method_name
        end

        def method_name=(value) # leftovers:call method_name=
        end

        def method_name? # leftovers:call method_name?
        end

        def method_name! # leftovers:call method_name!
        end
      RUBY
    end

    it do
      expect(subject).to have_definitions(
        :method_name, :method_name?, :method_name=, :method_name!
      ).and(have_calls(
        :method_name, :method_name?, :method_name=, :method_name!
      ))
    end
  end

  context 'with inline comment calls for constants' do
    let(:ruby) do
      <<~RUBY
        OVERRIDDEN_CONSTANT='trash' # leftovers:call OVERRIDDEN_CONSTANT

        class MyConstant # leftovers:call MyConstant
        end
      RUBY
    end

    it do
      expect(subject).to have_definitions(
        :MyConstant, :OVERRIDDEN_CONSTANT
      ).and(have_calls(
        :MyConstant, :OVERRIDDEN_CONSTANT
      ))
    end
  end

  context 'with inline comment allows for constants' do
    let(:ruby) do
      <<~RUBY
        OVERRIDDEN_CONSTANT='trash' # leftovers:allow

        class MyConstant # leftovers:allow
        end
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_no_calls) }
  end

  context 'with multiple inline comment allows for non alpha methods' do
    let(:ruby) do
      <<~RUBY
        # leftovers:call [] []= ** ! ~ +@ -@ * / % + - >> <<
        # leftovers:call & ^ | <= < > >= <=> == === != =~ !~
      RUBY
    end

    it do
      expect(subject).to have_no_definitions.and(have_calls(
        :[], :[]=, :**, :!, :~, :+@, :-@, :*, :/, :%, :+, :-, :>>, :<<,
        :&, :^, :|, :<=, :<, :>, :>=, :<=>, :==, :===, :'!=', :=~, :!~
      ))
    end
  end
end
