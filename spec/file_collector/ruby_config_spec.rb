# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::FileCollector do
  subject(:collector) do
    collector = described_class.new(ruby, file)
    collector.collect
    collector
  end

  before { Leftovers.reset }

  after { Leftovers.reset }

  let(:path) { 'foo.rb' }
  let(:file) { Leftovers::File.new(Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with method calls using send' do
    let(:ruby) { 'send(:foo)' }

    it { is_expected.to have_no_definitions.and(have_calls(:send, :foo)) }
  end

  context 'with method definitions using attr_reader' do
    let(:ruby) { 'attr_reader(:cat)' }

    it { is_expected.to have_definitions(:cat).and(have_calls(:attr_reader, :@cat)) }
  end

  context 'with method definitions using attr_accessor' do
    let(:ruby) { 'attr_accessor(:cat)' }

    it { is_expected.to have_definitions(:cat, :cat=).and(have_calls(:attr_accessor, :@cat)) }
  end

  context 'with method definitions using attr_writer' do
    let(:ruby) { 'attr_writer(:cat)' }

    it { is_expected.to have_definitions(:cat=).and(have_calls(:attr_writer)) }
  end

  context 'with method calls using send with strings' do
    let(:ruby) { 'send("foo")' }

    it { is_expected.to have_no_definitions.and(have_calls(:send, :foo)) }
  end

  context 'with method calls using send with lvars' do
    let(:ruby) { 'send(foo)' }

    it { is_expected.to have_no_definitions.and(have_calls(:send, :foo)) }
  end

  context 'with method calls using send with interpolated lvars' do
    let(:ruby) do
      <<~RUBY
        send("foo\#{bar}")
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:send, :bar)) }
  end

  context 'with dynamic comment allows' do
    let(:ruby) { <<~RUBY }
      attr_reader :method_name # leftovers:allow
    RUBY

    it { is_expected.to have_no_definitions.and(have_calls(:attr_reader, :@method_name)) }
  end

  context 'with alias_method arguments' do
    let(:ruby) { 'alias_method :new_method, :original_method' }

    it do
      expect(subject).to have_definitions(:new_method)
        .and have_calls(:alias_method, :original_method)
    end
  end

  context "when alias_method arguments aren't symbols" do
    let(:ruby) do
      <<~RUBY
        a = :whatever
        b = :whichever
        alias_method a, b
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:alias_method)) }
  end

  context 'with a processing error' do
    before do
      allow_any_instance_of(::Leftovers::Rule) # rubocop:disable RSpec/AnyInstance
        .to receive(:match?).and_raise(ArgumentError, 'original message')
      # not even going to try to find the correct object.
    end

    let(:ruby) { 'attr_reader :method_name # leftovers:allow' }

    it 'raises an error with the filename of the file being checked' do
      expect { collector }.to raise_error(
        ArgumentError, "original message\nwhen processing attr_reader at foo.rb:1:0"
      )
    end
  end

  context 'with multiple inline comment allows' do
    let(:ruby) do
      <<~RUBY
        method_names = [
          :method_name_1,
          :method_name_1?,
          :method_name_1=,
          :method_name_1!,
        ]
        # leftovers:call method_name_1, method_name_1? method_name_1=, method_name_1!
        method_names.each { |n| send(n) }
      RUBY
    end

    it do
      expect(subject).to have_no_definitions.and(have_calls(
        :method_name_1, :method_name_1?, :method_name_1=, :method_name_1!,
        :each, :send
      ))
    end
  end
end
