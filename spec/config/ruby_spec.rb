# frozen_string_literal: true

require 'spec_helper'

::RSpec.describe 'ruby and stdlib' do
  subject(:collector) do
    collector = ::Leftovers::FileCollector.new(ruby, file)
    collector.collect
    collector
  end

  let(:path) { 'foo.rb' }
  let(:file) { ::Leftovers::File.new(::Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with method calls using send' do
    let(:ruby) { 'send(:foo)' }

    it { is_expected.to have_no_definitions.and(have_calls(:send, :foo)) }
  end

  context 'with method defined in instance_eval' do
    let(:ruby) do
      <<~RUBY
        instance_eval <<~MY_RUBY, __FILE__, __LINE__ + 1
          def whatever; end
        MY_RUBY
      RUBY
    end

    it { is_expected.to have_definitions(:whatever).and(have_calls(:+, :instance_eval)) }
  end

  context 'with block passed to instance_eval' do
    let(:ruby) { 'instance_eval { 1 + 1 }' }

    it { is_expected.to have_no_definitions.and(have_calls(:+, :instance_eval)) }
  end

  context 'with a variable passed to instance_eval' do
    let(:ruby) { 'instance_eval a_method_call' }

    it { is_expected.to have_no_definitions.and(have_calls(:instance_eval, :a_method_call)) }
  end

  context 'with an empty string passed to instance_eval (why?)' do
    let(:ruby) { 'instance_eval ""' }

    it { is_expected.to have_no_definitions.and(have_calls(:instance_eval)) }
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

  context 'with method calls using send with methods' do
    let(:ruby) do
      <<~RUBY
        def foo; end
        send(foo)
      RUBY
    end

    it { is_expected.to have_definitions(:foo).and(have_calls(:send, :foo)) }
  end

  context 'with methods defined using &block' do
    let(:ruby) do
      <<~RUBY
        def foo(&block); end
      RUBY
    end

    it { is_expected.to have_definitions(:foo).and(have_no_calls) }
  end

  context 'with method calls using send with interpolated lvars' do
    let(:ruby) do
      <<~RUBY
        send("foo\#{bar}")
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:send, :bar)) }
  end

  context 'with instance_variable_get' do
    let(:ruby) { 'instance_variable_get(:@foo)' }

    it { is_expected.to have_no_definitions.and(have_calls(:instance_variable_get, :@foo)) }
  end

  context 'with class_variable_get' do
    let(:ruby) { 'class_variable_get(:@@foo)' }

    it { is_expected.to have_no_definitions.and(have_calls(:class_variable_get, :@@foo)) }
  end

  context 'with instance_variable_set' do
    let(:ruby) { 'instance_variable_set(:@foo, value)' }

    it { is_expected.to have_definitions(:@foo).and(have_calls(:instance_variable_set, :value)) }
  end

  context 'with class_variable_set' do
    let(:ruby) { 'class_variable_set(:@@foo, value)' }

    it { is_expected.to have_definitions(:@@foo).and(have_calls(:class_variable_set, :value)) }
  end

  context 'with define_method' do
    let(:ruby) { 'define_method(:foo) { value }' }

    it { is_expected.to have_definitions(:foo).and(have_calls(:define_method, :value)) }
  end

  context 'with dynamic comment allows' do
    let(:ruby) { <<~RUBY }
      attr_reader :method_name # leftovers:allow
    RUBY

    it { is_expected.to have_no_definitions.and(have_calls(:attr_reader, :@method_name)) }
  end

  context 'with dynamic comment test only' do
    let(:ruby) { <<~RUBY }
      attr_reader :method_name # leftovers:test
    RUBY

    it do
      expect(subject).to have_no_non_test_definitions
        .and(have_test_only_definitions(:method_name))
        .and(have_calls(:attr_reader, :@method_name))
    end
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

  context 'when alias_method arguments are sends' do
    let(:ruby) do
      <<~RUBY
        alias_method a(), b()
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:alias_method, :a, :b)) }
  end

  context 'with a processing error' do
    before do
      allow(::Leftovers::Processors::AddCall)
        .to receive(:process).and_raise(::ArgumentError, 'original message')
    end

    let(:ruby) { 'attr_reader :method_name # leftovers:allow' }

    it 'raises an error with the filename of the file being checked' do
      expect { collector }.to raise_error(
        ::Leftovers::Error,
        "ArgumentError: original message\n  when processing attr_reader at foo.rb:1:0"
      )
    end
  end

  context 'with a processing error within eval' do
    before do
      allow(::Leftovers::Processors::AddCall)
        .to receive(:process).and_raise(::ArgumentError, 'original message')
    end

    let(:ruby) do
      <<~RUBY
        "a string to offset things"
        instance_eval <<~MY_RUBY, __FILE__, __LINE__ + 1
          "something else"; attr_reader :method_name # leftovers:allow
        MY_RUBY
      RUBY
    end

    # this seems to be the wrong line because of heredoc weirdness i don't want to solve today
    it 'raises an error with the filename of the file being checked' do
      expect { collector }.to raise_error(
        ::Leftovers::Error,
        "ArgumentError: original message\n  when processing attr_reader at foo.rb:2:32"
      )
    end
  end

  context 'with a collector error within eval' do
    before do
      allow(::Leftovers::FileCollector::NodeProcessor)
        .to receive(:new).and_raise(::ArgumentError, 'original message')
    end

    let(:ruby) do
      <<~RUBY
        "a string to offset things"
        instance_eval <<~MY_RUBY, __FILE__, __LINE__ + 1
          "something else"; attr_reader :method_name # leftovers:allow
        MY_RUBY
      RUBY
    end

    # this seems to be the wrong line because of heredoc weirdness i don't want to solve today
    it 'raises an error with the filename of the file being checked' do
      expect { collector }.to raise_error(
        ::Leftovers::Error,
        "ArgumentError: original message\n  when processing foo.rb"
      )
    end
  end

  context 'with # leftovers:call # without any name' do
    let(:ruby) do
      <<~RUBY
        # leftovers:call #
        variable = :test
        send(variable)
      RUBY
    end

    it { is_expected.to have_no_definitions.and(have_calls(:send)) }
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
