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

  context 'with def method' do
    let(:ruby) { 'def m(a) a end' }

    it { is_expected.to have_definitions(:m).and(have_no_calls) }
  end

  context 'with method calls in optional arguments' do
    let(:ruby) { 'def m(a = b) a end' }

    it { is_expected.to have_definitions(:m).and(have_calls(:b)) }
  end

  context 'with method calls that match a previously defined lvar' do
    let(:ruby) { 'def m(a) self.a end' }

    it { is_expected.to have_definitions(:m).and(have_calls(:a)) }
  end

  context 'with method calls using Symbol#to_proc' do
    let(:ruby) { 'array.each(&:foo)' }

    it { is_expected.to have_no_definitions.and(have_calls(:array, :each, :foo)) }
  end

  context 'with method calls block pass' do
    let(:ruby) do
      <<~RUBY
        def my_method(&block)
          array.each(&block)
        end
      RUBY
    end

    it { is_expected.to have_definitions(:my_method).and(have_calls(:array, :each)) }
  end

  context 'with method calls using =' do
    let(:ruby) { 'self.foo = 1' }

    it { is_expected.to have_no_definitions.and(have_calls(:foo=)) }
  end

  context 'with method calls using +=' do
    let(:ruby) { 'self.foo += 1' }

    it { is_expected.to have_no_definitions.and(have_calls(:foo=, :foo)) }
  end

  context 'with method calls using *=' do
    let(:ruby) { 'self.foo *= 1' }

    it { is_expected.to have_no_definitions.and(have_calls(:foo=, :foo)) }
  end

  context 'with method calls using ||=' do
    let(:ruby) { 'self.foo ||= 1' }

    it { is_expected.to have_no_definitions.and(have_calls(:foo=, :foo)) }
  end

  context 'with method calls using &&=' do
    let(:ruby) { 'self.foo &&= 1' }

    it { is_expected.to have_no_definitions.and(have_calls(:foo=, :foo)) }
  end

  context 'with ivar definitions' do
    let(:ruby) { '@foo = 1' }

    it { is_expected.to have_definitions(:@foo).and(have_no_calls) }
  end

  context 'with ivar calls using +=' do
    let(:ruby) { '@foo += 1' }

    it { is_expected.to have_definitions(:@foo).and(have_calls(:@foo)) }
  end

  context 'with ivar calls using *=' do
    let(:ruby) { '@foo *= 1' }

    it { is_expected.to have_definitions(:@foo).and(have_calls(:@foo)) }
  end

  context 'with ivar calls using ||=' do
    let(:ruby) { '@foo ||= 1' }

    it { is_expected.to have_definitions(:@foo).and(have_calls(:@foo)) }
  end

  context 'with ivar calls using &&=' do
    let(:ruby) { '@foo &&= 1' }

    it { is_expected.to have_definitions(:@foo).and(have_calls(:@foo)) }
  end

  context 'with ivar calls' do
    let(:ruby) { 'puts @foo' }

    it { is_expected.to have_no_definitions.and(have_calls(:@foo, :puts)) }
  end

  context 'with gvar definitions' do
    let(:ruby) { '$foo = 1' }

    it { is_expected.to have_definitions(:$foo).and(have_no_calls) }
  end

  context 'with gvar calls using +=' do
    let(:ruby) { '$foo += 1' }

    it { is_expected.to have_definitions(:$foo).and(have_calls(:$foo)) }
  end

  context 'with gvar calls using *=' do
    let(:ruby) { '$foo *= 1' }

    it { is_expected.to have_definitions(:$foo).and(have_calls(:$foo)) }
  end

  context 'with gvar calls using ||=' do
    let(:ruby) { '$foo ||= 1' }

    it { is_expected.to have_definitions(:$foo).and(have_calls(:$foo)) }
  end

  context 'with gvar calls using &&=' do
    let(:ruby) { '$foo &&= 1' }

    it { is_expected.to have_definitions(:$foo).and(have_calls(:$foo)) }
  end

  context 'with gvar calls' do
    let(:ruby) { 'puts $foo' }

    it { is_expected.to have_no_definitions.and(have_calls(:$foo, :puts)) }
  end

  context 'with cvar definitions' do
    let(:ruby) { '@@foo = 1' }

    it { is_expected.to have_definitions(:@@foo).and(have_no_calls) }
  end

  context 'with cvar calls using +=' do
    let(:ruby) { '@@foo += 1' }

    it { is_expected.to have_definitions(:@@foo).and(have_calls(:@@foo)) }
  end

  context 'with cvar calls using *=' do
    let(:ruby) { '@@foo *= 1' }

    it { is_expected.to have_definitions(:@@foo).and(have_calls(:@@foo)) }
  end

  context 'with cvar calls using ||=' do
    let(:ruby) { '@@foo ||= 1' }

    it { is_expected.to have_definitions(:@@foo).and(have_calls(:@@foo)) }
  end

  context 'with cvar calls using &&=' do
    let(:ruby) { '@@foo &&= 1' }

    it { is_expected.to have_definitions(:@@foo).and(have_calls(:@@foo)) }
  end

  context 'with cvar calls' do
    let(:ruby) { 'puts @@foo' }

    it { is_expected.to have_no_definitions.and(have_calls(:puts, :@@foo)) }
  end

  context 'with method calls that match a previously defined lvar in a different context' do
    let(:ruby) { 'def m(a) nil end; a' }

    it { is_expected.to have_definitions(:m).and(have_calls(:a)) }
  end

  context 'with constant references' do
    let(:ruby) { 'Whatever.new' }

    it { is_expected.to have_no_definitions.and(have_calls(:Whatever, :new)) }
  end

  context 'with class definitions' do
    let(:ruby) { 'class Whatever; end' }

    it { is_expected.to have_definitions(:Whatever).and(have_no_calls) }
  end

  context 'with class definitions and constant calls to the inheritance class' do
    let(:ruby) { 'class Whatever < SuperClass; end' }

    it { is_expected.to have_definitions(:Whatever).and(have_calls(:SuperClass)) }
  end

  context 'with module definitions' do
    let(:ruby) { 'module Whatever; end' }

    it { is_expected.to have_definitions(:Whatever).and(have_no_calls) }
  end

  context 'with constant assignment' do
    let(:ruby) { 'Whatever = Class.new' }

    it { is_expected.to have_definitions(:Whatever).and(have_calls(:Class, :new)) }
  end

  context 'with method calls in hash values' do
    let(:ruby) { '{ call: this }' }

    it { is_expected.to have_no_definitions.and(have_calls(:this)) }
  end

  context 'with used in scope as calls' do
    let(:ruby) { 'A::B' }

    it { is_expected.to have_no_definitions.and(have_calls(:A, :B)) }
  end

  context 'with alias arguments' do
    let(:ruby) { 'alias new_method original_method' }

    it { is_expected.to have_definitions(:new_method).and(have_calls(:original_method)) }
  end

  context 'with lazy method calls' do
    let(:ruby) { 'this&.that' }

    it { is_expected.to have_no_definitions.and(have_calls(:this, :that)) }
  end

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
      expect(collector.definitions.map(&:test?)).to eq([true, true, true, true])
      expect(collector).to have_no_calls
        .and have_definitions(:method_name, :method_name?, :method_name=, :method_name!)
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
        :[], :[]=, :**, :'!', :~, :+@, :-@, :*, :/, :%, :+, :-, :>>, :<<,
        :&, :^, :|, :<=, :<, :>, :>=, :<=>, :==, :===, :'!=', :=~, :!~
      ))
    end
  end

  context 'with syntax errors' do
    let(:ruby) do
      <<~RUBY
        true
        a(b,c
      RUBY
    end

    it 'has an error message' do
      expect do
        collector
      end.to output(
        "\e[2K\e[31mfoo.rb:3:0 SyntaxError: unexpected token $end\e[0m\n"
      ).to_stderr
    end
  end
end
