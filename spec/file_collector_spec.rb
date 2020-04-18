# frozen_string_literal: true

require 'spec_helper'

RSpec::Matchers.define_negated_matcher :exclude, :include
RSpec.describe Leftovers::FileCollector do
  before { Leftovers.reset }
  after { Leftovers.reset }

  let(:file) { Leftovers::File.new(Leftovers.pwd + (@path || 'foo.rb')) }
  subject { described_class.new(@ruby, file) }

  it 'collects method definitions' do
    @ruby = 'def m(a) a end'

    subject.collect

    expect(subject.definitions).to have_names :m
  end

  it 'collects method calls in optional arguments' do
    @ruby = 'def m(a = b) a end'

    subject.collect

    expect(subject.definitions).to have_names :m
    expect(subject.calls).to contain_exactly :b
  end

  it 'collects method calls that match a previously defined lvar' do
    @ruby = 'def m(a) self.a end'

    subject.collect

    expect(subject.definitions).to have_names :m
    expect(subject.calls).to contain_exactly :a
  end

  it 'collects method calls using send' do
    @ruby = 'send(:foo)'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :send, :foo
  end

  it 'collects method definitions using attr_reader' do
    @ruby = 'attr_reader(:cat)'

    subject.collect

    expect(subject.definitions).to have_names(:cat)
    expect(subject.calls).to contain_exactly :attr_reader, :@cat
  end

  it 'collects method definitions using attr_accessor' do
    @ruby = 'attr_accessor(:cat)'

    subject.collect

    expect(subject.definitions).to have_names(:cat, :cat=)
    expect(subject.calls).to contain_exactly :attr_accessor, :@cat
  end

  it 'collects method definitions using attr_writer' do
    @ruby = 'attr_writer(:cat)'

    subject.collect

    expect(subject.definitions).to have_names(:cat=)
    expect(subject.calls).to contain_exactly :attr_writer
  end

  it 'collects method calls using send with strings' do
    @ruby = 'send("foo")'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :send, :foo
  end

  it 'collects method calls using Symbol#to_proc' do
    @ruby = 'array.each(&:foo)'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :array, :each, :foo
  end

  it 'collects method calls using =' do
    @ruby = 'self.foo = 1'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :foo=
  end

  it 'collects method calls using +=' do
    @ruby = 'self.foo += 1'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :foo=, :foo
  end

  it 'collects method calls using *=' do
    @ruby = 'self.foo *= 1'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :foo=, :foo
  end

  it 'collects method calls using ||=' do
    @ruby = 'self.foo ||= 1'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :foo=, :foo
  end

  it 'collects method calls using &&=' do
    @ruby = 'self.foo &&= 1'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :foo=, :foo
  end

  it 'collects ivar definitions' do
    @ruby = '@foo = 1'

    subject.collect

    expect(subject.definitions).to have_names :@foo
    expect(subject.calls).to be_empty
  end

  it 'collects ivar calls using +=' do
    @ruby = '@foo += 1'

    subject.collect

    expect(subject.definitions).to have_names :@foo
    expect(subject.calls).to contain_exactly :@foo
  end

  it 'collects ivar calls using *=' do
    @ruby = '@foo *= 1'

    subject.collect

    expect(subject.definitions).to have_names :@foo
    expect(subject.calls).to contain_exactly :@foo
  end

  it 'collects ivar calls using ||=' do
    @ruby = '@foo ||= 1'

    subject.collect

    expect(subject.definitions).to have_names :@foo
    expect(subject.calls).to contain_exactly :@foo
  end

  it 'collects ivar calls using &&=' do
    @ruby = '@foo &&= 1'

    subject.collect

    expect(subject.definitions).to have_names :@foo
    expect(subject.calls).to contain_exactly :@foo
  end

  it 'collects gvar definitions' do
    @ruby = '$foo = 1'

    subject.collect

    expect(subject.definitions).to have_names :$foo
    expect(subject.calls).to be_empty
  end

  it 'collects gvar calls using +=' do
    @ruby = '$foo += 1'

    subject.collect

    expect(subject.definitions).to have_names :$foo
    expect(subject.calls).to contain_exactly :$foo
  end

  it 'collects gvar calls using *=' do
    @ruby = '$foo *= 1'

    subject.collect

    expect(subject.definitions).to have_names :$foo
    expect(subject.calls).to contain_exactly :$foo
  end

  it 'collects gvar calls using ||=' do
    @ruby = '$foo ||= 1'

    subject.collect

    expect(subject.definitions).to have_names :$foo
    expect(subject.calls).to contain_exactly :$foo
  end

  it 'collects gvar calls using &&=' do
    @ruby = '$foo &&= 1'

    subject.collect

    expect(subject.definitions).to have_names :$foo
    expect(subject.calls).to contain_exactly :$foo
  end

  it 'collects cvar definitions' do
    @ruby = '@@foo = 1'

    subject.collect

    expect(subject.definitions).to have_names :@@foo
    expect(subject.calls).to be_empty
  end

  it 'collects cvar calls using +=' do
    @ruby = '@@foo += 1'

    subject.collect

    expect(subject.definitions).to have_names :@@foo
    expect(subject.calls).to contain_exactly :@@foo
  end

  it 'collects cvar calls using *=' do
    @ruby = '@@foo *= 1'

    subject.collect

    expect(subject.definitions).to have_names :@@foo
    expect(subject.calls).to contain_exactly :@@foo
  end

  it 'collects cvar calls using ||=' do
    @ruby = '@@foo ||= 1'

    subject.collect

    expect(subject.definitions).to have_names :@@foo
    expect(subject.calls).to contain_exactly :@@foo
  end

  it 'collects cvar calls using &&=' do
    @ruby = '@@foo &&= 1'

    subject.collect

    expect(subject.definitions).to have_names :@@foo
    expect(subject.calls).to contain_exactly :@@foo
  end

  context 'when rspec' do
    before do
      Leftovers.config << Leftovers::Config.new('rspec')
    end

    it 'collects method calls using be_' do
      @ruby = 'expect(array).to be_empty'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly :expect, :array, :to, :empty?, :be_empty
    end
  end

  context 'when rails' do
    before do
      Leftovers.config << Leftovers::Config.new('rails')
    end

    it 'collects method calls using a method that calls multiple methods' do
      @ruby = 'before_action :method_one, :method_two'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly :before_action, :method_one, :method_two
    end

    it 'collects method calls using a method that calls multiple methods with keyword arguments' do
      @ruby = 'skip_before_action :method_one, :method_two, if: :other_method?'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(
        :skip_before_action, :method_one, :method_two, :other_method?
      )
    end

    it 'collects method calls passed to before_save if:' do
      @ruby = 'before_save :do_a_thing, if: :thing_to_be_done?'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly :before_save, :do_a_thing, :thing_to_be_done?
    end

    it 'collects method calls passed in an array to a before_save if:' do
      @ruby = 'before_save :do_a_thing, if: [:thing_to_be_done?, :another_thing?]'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(
        :before_save, :do_a_thing, :thing_to_be_done?, :another_thing?
      )
    end

    it 'collects method calls in route values' do
      @ruby = 'patch :thing, to: "users#logout"'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:patch, :thing, :UsersController, :logout)
    end

    it 'collects scoped constant calls in class_name symbol keys' do
      @ruby = 'has_many :whatever, class_name: "Which::Ever"'

      subject.collect

      expect(subject.definitions).to have_names(:whatever, :whatever=)
      expect(subject.calls).to contain_exactly(:has_many, :Which, :Ever)
    end

    it 'collects hash key calls' do
      @ruby = 'validates test: true, other: :bar, presence: true'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(
        :TestValidator, :validates, :OtherValidator, :PresenceValidator
      )
    end

    it 'collects non-restful route calls' do
      @ruby = "get '/logout' => 'users#logout'"

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:UsersController, :get, :logout)
    end

    it 'collects routes controller calls' do
      @ruby = <<~RUBY
        controller :users do
          get :new
        end
      RUBY

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:controller, :UsersController, :get, :new)
    end

    it 'collects routes resource calls' do
      @ruby = 'resource :user'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:resource, :UsersController)
    end

    it 'collects delegation definitions and calls' do
      @ruby = 'delegate :foo, to: :bar'

      subject.collect

      # it's not a definition because it doesn't create any new method names
      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:delegate, :bar)
    end

    it 'collects delegation definitions and calls when prefix is defined' do
      @ruby = 'delegate :foo, :few, prefix: :bar, to: :baz'

      subject.collect

      expect(subject.definitions).to have_names(:bar_foo, :bar_few)
      expect(subject.calls).to contain_exactly(:delegate, :baz, :foo, :few)
    end

    it 'collects delegation definitions and calls when prefix is true' do
      @ruby = 'delegate :foo, :few, prefix: true, to: :bar'

      subject.collect

      expect(subject.definitions).to have_names(:bar_foo, :bar_few)
      expect(subject.calls).to contain_exactly(:delegate, :bar, :foo, :few)
    end

    it 'collects attribute assignment args' do
      @ruby = 'User.new(first_name: "Jane", last_name: "Smith")'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:User, :new, :first_name=, :last_name=)
    end

    it 'collects bang methods' do
      @ruby = 'User.create!'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:User, :create!)
    end

    it 'collects basic permit args' do
      @ruby = 'permit(:first_name, :last_name)'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:permit, :first_name=, :last_name=)
    end

    it 'collects hash permit args' do
      @ruby = 'permit(names: [:first_name, :last_name], age: :years)'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(
        :permit, :names=, :first_name=, :last_name=, :age=, :years=
      )
    end

    it 'collects deep permit args' do
      @ruby = <<~RUBY
        permit person_attributes: { names: [:first_name, :last_name, { deep: :hash}], age: :years }
      RUBY

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(
        :permit, :names=, :first_name=, :last_name=,
        :age=, :years=, :person_attributes=, :deep=, :hash=
      )
    end

    context 'with temp_dir' do
      around { |example| with_temp_dir { example.run } }
      it 'collects routes scope' do
        # need the files to actually exist or fast_ignore doesn't work.
        temp_file 'config/routes.rb'
        temp_file 'app/models/user.rb'

        @path = 'config/routes.rb'
        @ruby = <<~RUBY
          Rails.application.routes.draw do
            scope '/whatever', module: :whichever
          end
        RUBY

        subject.collect

        expect(subject.definitions).to be_empty
        expect(subject.calls).to contain_exactly(
          :Rails, :application, :routes, :draw, :scope, :Whichever
        )
      end

      it 'collects AR scope' do
        temp_file 'config/routes.rb'
        temp_file 'app/models/user.rb'

        @path = 'app/models/user.rb'
        @ruby = <<~RUBY
          class User < ApplicationRecord
            scope :whatever, -> { order(:whichever) }
          end
        RUBY

        subject.collect

        expect(subject.definitions).to have_names(:User, :whatever)
        expect(subject.calls).to contain_exactly(:ApplicationRecord, :lambda, :scope, :order)
      end
    end

    it 'collects validation calls' do
      @ruby = 'validate :validator_method_name, if: :condition?'

      subject.collect

      expect(subject.definitions).to be_empty
      expect(subject.calls).to contain_exactly(:validate, :validator_method_name, :condition?)
    end

    it 'collects validations calls inclusion method' do
      @ruby = <<~RUBY
        validates :name, presence: true, inclusion: :inclusion_method, if: :condition?
      RUBY

      subject.collect

      expect(subject.definitions).to be_empty
      # IfValidator is awkward, but fine
      expect(subject.calls).to contain_exactly(
        :validates, :name, :inclusion_method, :condition?,
        :PresenceValidator, :IfValidator, :InclusionValidator
      )
    end

    it 'collects validations calls with inclusion hash' do
      @ruby = <<~RUBY
        validates :name, presence: true, inclusion: { in: :inclusion_method }, if: :condition?
      RUBY

      subject.collect

      expect(subject.definitions).to be_empty
      # IfValidator is awkward, but fine
      expect(subject.calls).to contain_exactly(
        :validates, :name, :inclusion_method, :condition?,
        :PresenceValidator, :IfValidator, :InclusionValidator
      )
    end
  end

  it 'copes with method calls using send with lvars' do
    @ruby = 'send(foo)'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :send, :foo
  end

  it 'copes with method calls using send with interpolated lvars' do
    @ruby = <<~RUBY
      send("foo\#{bar}")
    RUBY

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :send, :bar
  end

  it 'collects method calls that match a previously defined lvar in a different context' do
    @ruby = 'def m(a) nil end; a'

    subject.collect

    expect(subject.definitions).to have_names :m
    expect(subject.calls).to contain_exactly :a
  end

  it 'collects constant references' do
    @ruby = 'Whatever.new'

    subject.collect

    expect(subject.calls).to contain_exactly :Whatever, :new
    expect(subject.definitions).to be_empty
  end

  it 'collects class definitions' do
    @ruby = 'class Whatever; end'

    subject.collect

    expect(subject.definitions).to have_names :Whatever
    expect(subject.calls).to be_empty
  end

  it 'collects class definitions and constant calls to the inheritance class' do
    @ruby = 'class Whatever < SuperClass; end'

    subject.collect

    expect(subject.definitions).to have_names :Whatever
    expect(subject.calls).to contain_exactly :SuperClass
  end

  it 'collects module definitions' do
    @ruby = 'module Whatever; end'

    subject.collect

    expect(subject.definitions).to have_names :Whatever
    expect(subject.calls).to be_empty
  end

  it 'collects constant assignment' do
    @ruby = 'Whatever = Class.new'

    subject.collect

    expect(subject.definitions).to have_names :Whatever
    expect(subject.calls).to contain_exactly :Class, :new
  end

  it 'collects haml files' do
    @ruby = Leftovers::Haml.precompile '= a'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a)
  end

  it 'collects haml files with hidden scripts' do
    @ruby = Leftovers::Haml.precompile '- a'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :a
  end

  it 'collects haml files string interpolation' do
    @ruby = Leftovers::Haml.precompile <<~HAML
      before\#{a}after
    HAML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a).and(exclude(:before, :after))
  end

  it 'collects haml files with ruby blocks' do
    @ruby = Leftovers::Haml.precompile <<~HAML
      :ruby
        a(1)
    HAML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a).and(exclude(:ruby))
  end

  it 'collects haml files with dynamic attributes' do
    @ruby = Leftovers::Haml.precompile '%div{id: a}'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a).and(exclude(:id, :div))
  end

  it 'collects haml files with whitespace-significant blocks' do
    @ruby = Leftovers::Haml.precompile <<~HAML
      - foo.each do |bar|
        = bar
    HAML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:foo, :each).and(exclude(:bar))
  end

  it 'collects haml files with echoed whitespace-significant blocks' do
    @ruby = Leftovers::Haml.precompile <<~HAML
      = form_for(whatever) do |bar|
        = bar
    HAML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:form_for, :whatever).and(exclude(:bar))
  end

  it 'collects erb files' do
    @ruby = Leftovers::ERB.precompile '<a href="<%= whatever %>">label</a>'

    subject.collect

    expect(subject.definitions).to be_empty
    # the extra options are internal erb stuff and i don't mind
    expect(subject.calls).to include(:whatever).and(exclude(:a, :href, :label))
  end

  it 'collects erb files when newline trimmed' do
    @ruby = Leftovers::ERB.precompile <<~ERB
      <%- if foo.present? -%>
        <a href="<%= foo %>">label</a>
      <%- end -%>
    ERB

    subject.collect

    expect(subject.definitions).to be_empty
    # the extra options are internal erb stuff and i don't mind
    expect(subject.calls).to include(:foo, :present?).and(exclude(:a, :href, :label))
  end

  it 'collects method calls in hash values' do
    @ruby = '{ call: this }'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:this)
  end

  it 'collects used in scope as calls' do
    @ruby = 'A::B'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:A, :B)
  end

  it 'collects alias method arguments' do
    @ruby = 'alias_method :new_method, :original_method'

    subject.collect

    expect(subject.definitions).to have_names(:new_method)
    expect(subject.calls).to contain_exactly(:alias_method, :original_method)
  end

  it "doesn't collect alias method arguments that aren't symbols" do
    @ruby = <<~RUBY
      a = :whatever
      b = :whichever
      alias_method a, b
    RUBY

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:alias_method)
  end

  it 'collects alias arguments' do
    @ruby = 'alias new_method original_method'

    subject.collect

    expect(subject.definitions).to have_names(:new_method)
    expect(subject.calls).to contain_exactly(:original_method)
  end

  it 'collects lazy method calls' do
    @ruby = 'this&.that'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:this, :that)
  end

  it 'collects inline comment allows' do
    @ruby = <<~RUBY
      def method_name # leftovers:call method_name
      end

      def method_name=(value) # leftovers:call method_name=
      end

      def method_name? # leftovers:call method_name?
      end

      def method_name! # leftovers:call method_name!
      end
    RUBY

    subject.collect
    expect(subject.definitions).to have_names(
      :method_name, :method_name?, :method_name=, :method_name!
    )
    expect(subject.calls).to contain_exactly(
      :method_name, :method_name?, :method_name=, :method_name!
    )
  end

  it 'collects inline comment allows for constants' do
    @ruby = <<~RUBY
      OVERRIDDEN_CONSTANT='trash' # leftovers:call OVERRIDDEN_CONSTANT

      class MyConstant # leftovers:call MyConstant
      end
    RUBY

    subject.collect
    expect(subject.definitions).to have_names(
      :MyConstant, :OVERRIDDEN_CONSTANT
    )
    expect(subject.calls).to contain_exactly(
      :MyConstant, :OVERRIDDEN_CONSTANT
    )
  end

  it 'collects multiple inline comment allows' do
    @ruby = <<~RUBY
      method_names = [
        :method_name_1,
        :method_name_1?,
        :method_name_1=,
        :method_name_1!,
      ]
      # leftovers:call method_name_1, method_name_1? method_name_1=, method_name_1!
      method_names.each { |n| send(n) }
    RUBY

    subject.collect
    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(
      :method_name_1, :method_name_1?, :method_name_1=, :method_name_1!,
      :each, :send
    )
  end

  it 'collects multiple inline comment allows for non alpha methods' do
    @ruby = <<~RUBY
      # leftovers:call [] []= ** ! ~ +@ -@ * / % + - >> <<
      # leftovers:call & ^ | <= < > >= <=> == === != =~ !~
    RUBY

    subject.collect
    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(
      :[], :[]=, :**, :'!', :~, :+@, :-@, :*, :/, :%, :+, :-, :>>, :<<,
      :&, :^, :|, :<=, :<, :>, :>=, :<=>, :==, :===, :'!=', :=~, :!~
    )
  end

  it 'collects affixxed methods' do
    @ruby = 'test_html'

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      ---
      rules:
        - name:
            has_suffix: '_html'
          calls:
            - itself: true
              delete_suffix: _html
            - itself: true
              replace_with: html
    YML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:test, :html, :test_html)
  end

  it 'collects array values' do
    @ruby = 'flow(whatever, [:method_1, :method_2])'

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      ---
      rules:
        - name: flow
          calls:
            - argument: 2
    YML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:flow, :whatever, :method_1, :method_2)
  end

  it 'collects matched keyword arguments' do
    @ruby = 'flow(whatever, some_values: :method)'

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      ---
      rules:
        - name: flow
          calls:
            argument:
              has_prefix: some
    YML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:flow, :whatever, :method)
  end

  it "doesn't collect position or keyword lvars" do
    @ruby = <<~RUBY
      b = 1
      my_method(b, my_keyword: b)
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            argument: [1, my_keyword]
    YML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:my_method)
  end

  it "doesn't collect rest kwargs" do
    @ruby = <<~RUBY
      b = 1
      args = {}
      my_method(b, my_keyword: b, **args)
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            argument: [1, my_keyword]
    YML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly(:my_method)
  end

  it 'collects constant assignment values' do
    @ruby = <<~RUBY
      STRING_TRANSFORMS = %i{
        downcase
        upcase
      }
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: STRING_TRANSFORMS
          calls:
            argument: 1
    YML

    subject.collect

    expect(subject.definitions).to have_names :STRING_TRANSFORMS
    expect(subject.calls).to contain_exactly(:downcase, :upcase)
  end

  it 'collects constant assignment values with freeze' do
    @ruby = <<~RUBY
      STRING_TRANSFORMS = %i{
        downcase
        upcase
      }.freeze
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: STRING_TRANSFORMS
          calls:
            argument: 1
    YML

    subject.collect

    expect(subject.definitions).to have_names :STRING_TRANSFORMS
    expect(subject.calls).to contain_exactly(:downcase, :upcase, :freeze)
  end

  it 'collects constant hash assignment keys' do
    @ruby = <<~RUBY
      STRING_TRANSFORMS = {
        downcase: true,
        upcase: true
      }
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: STRING_TRANSFORMS
          calls:
            keys: true
    YML

    subject.collect

    expect(subject.definitions).to have_names :STRING_TRANSFORMS
    expect(subject.calls).to contain_exactly(:downcase, :upcase)
  end

  it 'collects constant hash assignment keys with freeze' do
    @ruby = <<~RUBY
      STRING_TRANSFORMS = {
        downcase: true,
        upcase: true
      }.freeze
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: STRING_TRANSFORMS
          calls:
            keys: true
    YML

    subject.collect

    expect(subject.definitions).to have_names :STRING_TRANSFORMS
    expect(subject.calls).to contain_exactly(:downcase, :upcase, :freeze)
  end

  it 'collects nested hash assignment values' do
    @ruby = <<~RUBY
      STRING_TRANSFORMS = {
        body: { process: :downcase },
        title: { process: :upcase }
      }
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: STRING_TRANSFORMS
          calls:
            arguments: '**'
    YML

    subject.collect

    expect(subject.definitions).to have_names :STRING_TRANSFORMS
    expect(subject.calls).to contain_exactly(:downcase, :upcase)
  end
end
