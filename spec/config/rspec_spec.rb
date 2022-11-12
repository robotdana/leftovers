# frozen_string_literal: true

require 'spec_helper'

::RSpec.describe 'rspec gem' do
  subject(:collector) do
    collector = ::Leftovers::FileCollector.new(ruby, file)
    collector.collect
    collector
  end

  before do
    ::Leftovers.config << :rspec
  end

  let(:path) { 'spec/file_spec.rb' }
  let(:file) { ::Leftovers::File.new(::Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with method calls using be_' do
    let(:ruby) { 'expect(array).to be_empty' }

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:expect, :array, :to, :empty?, :be_empty))
    end
  end

  context 'with method calls using have_' do
    let(:ruby) { 'expect(array).to have_key(:key)' }

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:expect, :array, :to, :has_key?, :have_key))
    end
  end

  context 'with method calls using receive_messages' do
    let(:ruby) { 'expect(array).to receive_messages(my_method: true)' }

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:expect, :array, :to, :receive_messages, :my_method))
    end
  end

  context 'with a custom matcher' do
    let(:ruby) do
      <<~RUBY
        ::RSpec::Matchers.define :custom_eq do |expected|
          match do |actual|
            actual == expected
          end
        end
      RUBY
    end

    it do
      expect(subject).to have_definitions(:custom_eq)
        .and(have_calls(:RSpec, :Matchers, :define, :match, :==))
    end
  end

  context 'with a custom matcher defined another way' do
    let(:ruby) do
      <<~RUBY
        # extend RSpec::Matchers::DSL
        matcher :custom_eq do |expected|
          match { |actual| actual == expected }
        end
      RUBY
    end

    it do
      expect(subject).to have_definitions(:custom_eq)
        .and(have_calls(:matcher, :match, :==))
    end
  end

  context 'with a custom alias matcher' do
    let(:ruby) do
      <<~RUBY
        # extend RSpec::Matchers::DSL
        RSpec::Matchers.alias_matcher :custom_eq, :eq
      RUBY
    end

    it do
      expect(subject).to have_definitions(:custom_eq)
        .and(have_calls(:RSpec, :Matchers, :alias_matcher, :eq))
    end
  end
end
