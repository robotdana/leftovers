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
end
