# frozen_string_literal: true

require 'spec_helper'

RSpec::Matchers.define_negated_matcher :exclude, :include
RSpec.describe Leftovers::FileCollector do
  before { Leftovers.reset }

  after { Leftovers.reset }

  let(:file) { Leftovers::File.new(Leftovers.pwd + 'foo.rb') }

  it 'collects method definitions' do
    ruby = 'def m(a) a end'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :m
  end

  it 'collects method calls in optional arguments' do
    ruby = 'def m(a = b) a end'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :m
    expect(collector.calls).to contain_exactly :b
  end

  it 'collects method calls that match a previously defined lvar' do
    ruby = 'def m(a) self.a end'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :m
    expect(collector.calls).to contain_exactly :a
  end

  it 'collects method calls using send' do
    ruby = 'send(:foo)'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :send, :foo
  end

  it 'collects method definitions using attr_reader' do
    ruby = 'attr_reader(:cat)'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names(:cat)
    expect(collector.calls).to contain_exactly :attr_reader, :@cat
  end

  it 'collects method definitions using attr_accessor' do
    ruby = 'attr_accessor(:cat)'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names(:cat, :cat=)
    expect(collector.calls).to contain_exactly :attr_accessor, :@cat
  end

  it 'collects method definitions using attr_writer' do
    ruby = 'attr_writer(:cat)'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names(:cat=)
    expect(collector.calls).to contain_exactly :attr_writer
  end

  it 'collects method calls using send with strings' do
    ruby = 'send("foo")'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :send, :foo
  end

  it 'collects method calls using Symbol#to_proc' do
    ruby = 'array.each(&:foo)'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :array, :each, :foo
  end

  it 'Works with method calls block pass' do
    ruby = <<~RUBY
      def my_method(&block)
        array.each(&block)
      end
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :my_method
    expect(collector.calls).to contain_exactly :array, :each
  end

  it 'collects method calls using =' do
    ruby = 'self.foo = 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :foo=
  end

  it 'collects method calls using +=' do
    ruby = 'self.foo += 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :foo=, :foo
  end

  it 'collects method calls using *=' do
    ruby = 'self.foo *= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :foo=, :foo
  end

  it 'collects method calls using ||=' do
    ruby = 'self.foo ||= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :foo=, :foo
  end

  it 'collects method calls using &&=' do
    ruby = 'self.foo &&= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :foo=, :foo
  end

  it 'collects ivar definitions' do
    ruby = '@foo = 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@foo
    expect(collector.calls).to be_empty
  end

  it 'collects ivar calls using +=' do
    ruby = '@foo += 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@foo
    expect(collector.calls).to contain_exactly :@foo
  end

  it 'collects ivar calls using *=' do
    ruby = '@foo *= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@foo
    expect(collector.calls).to contain_exactly :@foo
  end

  it 'collects ivar calls using ||=' do
    ruby = '@foo ||= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@foo
    expect(collector.calls).to contain_exactly :@foo
  end

  it 'collects ivar calls using &&=' do
    ruby = '@foo &&= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@foo
    expect(collector.calls).to contain_exactly :@foo
  end

  it 'collects ivar calls' do
    ruby = 'puts @foo'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :@foo, :puts
  end

  it 'collects gvar definitions' do
    ruby = '$foo = 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :$foo
    expect(collector.calls).to be_empty
  end

  it 'collects gvar calls using +=' do
    ruby = '$foo += 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :$foo
    expect(collector.calls).to contain_exactly :$foo
  end

  it 'collects gvar calls using *=' do
    ruby = '$foo *= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :$foo
    expect(collector.calls).to contain_exactly :$foo
  end

  it 'collects gvar calls using ||=' do
    ruby = '$foo ||= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :$foo
    expect(collector.calls).to contain_exactly :$foo
  end

  it 'collects gvar calls using &&=' do
    ruby = '$foo &&= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :$foo
    expect(collector.calls).to contain_exactly :$foo
  end

  it 'collects gvar calls' do
    ruby = 'puts $foo'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :$foo, :puts
  end

  it 'collects cvar definitions' do
    ruby = '@@foo = 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@@foo
    expect(collector.calls).to be_empty
  end

  it 'collects cvar calls using +=' do
    ruby = '@@foo += 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@@foo
    expect(collector.calls).to contain_exactly :@@foo
  end

  it 'collects cvar calls using *=' do
    ruby = '@@foo *= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@@foo
    expect(collector.calls).to contain_exactly :@@foo
  end

  it 'collects cvar calls using ||=' do
    ruby = '@@foo ||= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@@foo
    expect(collector.calls).to contain_exactly :@@foo
  end

  it 'collects cvar calls using &&=' do
    ruby = '@@foo &&= 1'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@@foo
    expect(collector.calls).to contain_exactly :@@foo
  end

  it 'collects cvar calls' do
    ruby = 'puts @@foo'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :puts, :@@foo
  end

  context 'when rspec' do
    before do
      with_temp_dir
      Leftovers.config << :rspec
    end

    let(:file) do
      temp_file 'spec/file_spec.rb' # the file needs to exist
      Leftovers::File.new(Leftovers.pwd + 'spec/file_spec.rb')
    end

    it 'collects method calls using be_' do
      ruby = 'expect(array).to be_empty'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly :expect, :array, :to, :empty?, :be_empty
    end
  end

  context 'when rails' do
    before do
      Leftovers.config << :rails
    end

    it 'collects method calls using a method that calls multiple methods' do
      ruby = 'before_action :method_one, :method_two'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly :before_action, :method_one, :method_two
    end

    it 'collects method calls using a method that calls multiple methods with keyword arguments' do
      ruby = 'skip_before_action :method_one, :method_two, if: :other_method?'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(
        :skip_before_action, :method_one, :method_two, :other_method?
      )
    end

    it 'collects method calls passed to before_save if:' do
      ruby = 'before_save :do_a_thing, if: :thing_to_be_done?'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly :before_save, :do_a_thing, :thing_to_be_done?
    end

    it 'collects method calls passed in an array to a before_save if:' do
      ruby = 'before_save :do_a_thing, if: [:thing_to_be_done?, :another_thing?]'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(
        :before_save, :do_a_thing, :thing_to_be_done?, :another_thing?
      )
    end

    it 'collects method calls in route values' do
      ruby = 'patch :thing, to: "users#logout"'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:patch, :thing, :UsersController, :logout)
    end

    it 'collects method calls in route root values' do
      ruby = 'root to: "home#index"'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:root, :HomeController, :index)
    end

    it 'collects method calls in namespaced route values' do
      ruby = 'get :admin, to: "administration/dashboard#index"'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(
        :get, :Administration, :admin, :DashboardController, :index
      )
    end

    it 'collects scoped constant calls in class_name symbol keys' do
      ruby = 'has_many :whatevers, class_name: "Which::Ever"'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to have_names(
        :whatevers, :whatevers=, :whatever_ids, :whatever_ids=
      )
      expect(collector.calls).to contain_exactly(:has_many, :Which, :Ever)
    end

    it 'collects hash key calls' do
      ruby = 'validates test: true, other: :bar, presence: true'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(
        :TestValidator, :validates, :OtherValidator, :PresenceValidator
      )
    end

    it 'collects non-restful route calls' do
      ruby = "get '/logout' => 'users#logout'"

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:UsersController, :get, :logout)
    end

    it 'collects routes controller calls' do
      ruby = <<~RUBY
        controller :users do
          get :new
        end
      RUBY

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:controller, :UsersController, :get, :new)
    end

    it 'collects routes resource calls' do
      ruby = 'resource :user'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:resource, :UsersController)
    end

    it 'collects delegation definitions and calls' do
      ruby = 'delegate :foo, to: :bar'

      collector = described_class.new(ruby, file)
      collector.collect

      # it's not a definition because it doesn't create any new method names
      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:delegate, :bar)
    end

    it 'collects delegation definitions and calls when prefix is defined' do
      ruby = 'delegate :foo, :few, prefix: :bar, to: :baz'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to have_names(:bar_foo, :bar_few)
      expect(collector.calls).to contain_exactly(:delegate, :baz, :foo, :few)
    end

    it 'collects delegation definitions and calls when prefix is true' do
      ruby = 'delegate :foo, :few, prefix: true, to: :bar'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to have_names(:bar_foo, :bar_few)
      expect(collector.calls).to contain_exactly(:delegate, :bar, :foo, :few)
    end

    it 'collects attribute assignment args' do
      ruby = 'User.new(first_name: "Jane", last_name: "Smith")'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:User, :new, :first_name=, :last_name=)
    end

    it 'collects bang methods' do
      ruby = 'User.create!'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:User, :create!)
    end

    it 'collects basic permit args' do
      ruby = 'permit(:first_name, :last_name)'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:permit, :first_name=, :last_name=)
    end

    it 'collects hash permit args' do
      ruby = 'permit(names: [:first_name, :last_name], age: :years)'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(
        :permit, :names=, :first_name=, :last_name=, :age=, :years=
      )
    end

    it 'collects deep permit args' do
      ruby = <<~RUBY
        permit person_attributes: { names: [:first_name, :last_name, { deep: :hash}], age: :years }
      RUBY

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(
        :permit, :names=, :first_name=, :last_name=,
        :age=, :years=, :person_attributes=, :deep=, :hash=
      )
    end

    context 'with temp_dir' do
      before { with_temp_dir }

      it 'collects routes scope' do
        # need the files to actually exist or fast_ignore doesn't work.
        temp_file 'config/routes.rb'

        file = Leftovers::File.new(Leftovers.pwd + 'config/routes.rb')
        ruby = <<~RUBY
          Rails.application.routes.draw do
            scope '/whatever', module: :whichever
          end
        RUBY

        collector = described_class.new(ruby, file)
        collector.collect

        expect(collector.definitions).to be_empty
        expect(collector.calls).to contain_exactly(
          :Rails, :application, :routes, :draw, :scope, :Whichever
        )
      end

      it 'collects AR scope' do
        temp_file 'config/routes.rb'
        temp_file 'app/models/user.rb'

        file = Leftovers::File.new(Leftovers.pwd + 'app/models/user.rb')
        ruby = <<~RUBY
          class User < ApplicationRecord
            scope :whatever, -> { order(:whichever) }
          end
        RUBY

        collector = described_class.new(ruby, file)
        collector.collect

        expect(collector.definitions).to have_names(:User, :whatever)
        expect(collector.calls).to contain_exactly(:ApplicationRecord, :lambda, :scope, :order)
      end
    end

    it 'collects validation calls' do
      ruby = 'validate :validator_method_name, if: :condition?'

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      expect(collector.calls).to contain_exactly(:validate, :validator_method_name, :condition?)
    end

    it 'collects validations calls inclusion method' do
      ruby = <<~RUBY
        validates :name, presence: true, inclusion: :inclusion_method, if: :condition?
      RUBY

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      # IfValidator is awkward, but fine
      expect(collector.calls).to contain_exactly(
        :validates, :name, :inclusion_method, :condition?,
        :PresenceValidator, :IfValidator, :InclusionValidator
      )
    end

    it 'collects validations calls with inclusion hash' do
      ruby = <<~RUBY
        validates :name, presence: true, inclusion: { in: :inclusion_method }, if: :condition?
      RUBY

      collector = described_class.new(ruby, file)
      collector.collect

      expect(collector.definitions).to be_empty
      # IfValidator is awkward, but fine
      expect(collector.calls).to contain_exactly(
        :validates, :name, :inclusion_method, :condition?,
        :PresenceValidator, :IfValidator, :InclusionValidator
      )
    end
  end

  it 'copes with method calls using send with lvars' do
    ruby = 'send(foo)'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :send, :foo
  end

  it 'copes with method calls using send with interpolated lvars' do
    ruby = <<~RUBY
      send("foo\#{bar}")
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :send, :bar
  end

  it 'collects method calls that match a previously defined lvar in a different context' do
    ruby = 'def m(a) nil end; a'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :m
    expect(collector.calls).to contain_exactly :a
  end

  it 'collects constant references' do
    ruby = 'Whatever.new'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.calls).to contain_exactly :Whatever, :new
    expect(collector.definitions).to be_empty
  end

  it 'collects class definitions' do
    ruby = 'class Whatever; end'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :Whatever
    expect(collector.calls).to be_empty
  end

  it 'collects class definitions and constant calls to the inheritance class' do
    ruby = 'class Whatever < SuperClass; end'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :Whatever
    expect(collector.calls).to contain_exactly :SuperClass
  end

  it 'collects module definitions' do
    ruby = 'module Whatever; end'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :Whatever
    expect(collector.calls).to be_empty
  end

  it 'collects constant assignment' do
    ruby = 'Whatever = Class.new'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :Whatever
    expect(collector.calls).to contain_exactly :Class, :new
  end

  it 'collects haml files' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      = a
    HAML

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to include(:a)
  end

  it 'handles invalid haml files' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      %a text
        %a text
    HAML

    expect do
      file.ruby
    end.to output(<<~STDERR).to_stderr
      \e[2KHaml::SyntaxError: Illegal nesting: content can't be both given on the same line as %a and nested within it. foo.haml:1
    STDERR
    expect(file.ruby).to eq('')

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to be_empty
  end

  it 'handles unavailable haml' do
    unless Leftovers.instance_variable_get(:@try_require)
      Leftovers.instance_variable_set(:@try_require, {})
    end
    allow(Leftovers.instance_variable_get(:@try_require))
      .to receive(:key?).with('haml').and_return(true)
    allow(Leftovers.instance_variable_get(:@try_require))
      .to receive(:[]).with('haml').and_return(false)

    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      %a text
    HAML

    expect do
      file.ruby
    end.to output(<<~OUTPUT).to_stderr
      \e[2KSkipped parsing foo.haml, because the haml gem was not available
      `gem install haml`
    OUTPUT

    expect(file.ruby).to eq ''
    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to be_empty
  end

  it 'collects haml files with hidden scripts' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      - a
    HAML

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :a
  end

  it 'collects haml files string interpolation' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      before\#{a}after
    HAML

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to include(:a).and(exclude(:before, :after))
  end

  it 'collects haml files with ruby blocks' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      :ruby
        a(1)
    HAML

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to include(:a).and(exclude(:ruby))
  end

  it 'collects haml files with dynamic attributes' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      %div{id: a}
    HAML

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to include(:a).and(exclude(:id, :div))
  end

  it 'collects haml files with whitespace-significant blocks' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      - foo.each do |bar|
        = bar
    HAML

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to include(:foo, :each).and(exclude(:bar))
  end

  it 'collects haml files with echoed whitespace-significant blocks' do
    file = Leftovers::File.new(Dir.pwd + '/foo.haml')
    allow(file).to receive(:read).and_return(<<~HAML)
      = form_for(whatever) do |bar|
        = bar
    HAML

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to include(:form_for, :whatever).and(exclude(:bar))
  end

  it 'collects erb files' do
    file = Leftovers::File.new(Dir.pwd + '/foo.erb')
    allow(file).to receive(:read).and_return(<<~ERB)
      <a href="<%= whatever %>">label</a>'
    ERB

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    # the extra options are internal erb stuff and i don't mind
    expect(collector.calls).to include(:whatever).and(exclude(:a, :href, :label))
  end

  it 'collects erb files when newline trimmed' do
    file = Leftovers::File.new(Dir.pwd + '/foo.erb')
    allow(file).to receive(:read).and_return(<<~ERB)
      <%- if foo.present? -%>
        <a href="<%= foo %>">label</a>
      <%- end -%>
    ERB

    collector = described_class.new(file.ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    # the extra options are internal erb stuff and i don't mind
    expect(collector.calls).to include(:foo, :present?).and(exclude(:a, :href, :label))
  end

  it 'collects method calls in hash values' do
    ruby = '{ call: this }'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:this)
  end

  it 'collects used in scope as calls' do
    ruby = 'A::B'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:A, :B)
  end

  it 'collects alias method arguments' do
    ruby = 'alias_method :new_method, :original_method'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names(:new_method)
    expect(collector.calls).to contain_exactly(:alias_method, :original_method)
  end

  it "doesn't collect alias method arguments that aren't symbols" do
    ruby = <<~RUBY
      a = :whatever
      b = :whichever
      alias_method a, b
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:alias_method)
  end

  it 'collects alias arguments' do
    ruby = 'alias new_method original_method'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names(:new_method)
    expect(collector.calls).to contain_exactly(:original_method)
  end

  it 'collects lazy method calls' do
    ruby = 'this&.that'

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:this, :that)
  end

  it 'collects inline comment allows' do
    ruby = <<~RUBY
      def method_name # leftovers:allow
      end

      def method_name=(value) # leftovers:allows
      end

      def method_name? # leftovers:allowed
      end

      def method_name! # leftovers:skip
      end
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to be_empty
    expect(collector.calls).to be_empty
  end

  it 'collects dynamic comment allows' do
    ruby = <<~RUBY
      attr_reader :method_name # leftovers:allow
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly :attr_reader, :@method_name
  end

  it 'shows the filename when there is an error with the processing' do
    allow_any_instance_of(Leftovers::ArgumentRule) # rubocop:disable RSpec/AnyInstance
      .to receive(:matches).and_raise(ArgumentError, 'original message')
    # not even going to try to find the correct object.

    ruby = <<~RUBY
      attr_reader :method_name # leftovers:allow
    RUBY

    collector = described_class.new(ruby, file)
    expect do
      collector.collect
    end.to raise_error(ArgumentError,
                       "original message\nwhen processing attr_reader at foo.rb:1:0")
  end

  it 'collects inline comment test' do
    ruby = <<~RUBY
      def method_name # leftovers:for_test
      end

      def method_name=(value) # leftovers:for_tests
      end

      def method_name? # leftovers:testing
      end

      def method_name! # leftovers:test
      end
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to have_names(
      :method_name, :method_name?, :method_name=, :method_name!
    )
    expect(collector.definitions.map(&:test?)).to eq([true, true, true, true])
    expect(collector.calls).to be_empty
  end

  it 'collects inline comment calls' do
    ruby = <<~RUBY
      def method_name # leftovers:call method_name
      end

      def method_name=(value) # leftovers:call method_name=
      end

      def method_name? # leftovers:call method_name?
      end

      def method_name! # leftovers:call method_name!
      end
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to have_names(
      :method_name, :method_name?, :method_name=, :method_name!
    )
    expect(collector.calls).to contain_exactly(
      :method_name, :method_name?, :method_name=, :method_name!
    )
  end

  it "doesn't break with a # leftovers:call # without any " do
    ruby = <<~RUBY
      # leftovers:call #
      variable = :test
      send(variable)
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:send)
  end

  it 'collects inline comment calls for constants' do
    ruby = <<~RUBY
      OVERRIDDEN_CONSTANT='trash' # leftovers:call OVERRIDDEN_CONSTANT

      class MyConstant # leftovers:call MyConstant
      end
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to have_names(
      :MyConstant, :OVERRIDDEN_CONSTANT
    )
    expect(collector.calls).to contain_exactly(
      :MyConstant, :OVERRIDDEN_CONSTANT
    )
  end

  it 'collects inline comment allows for constants' do
    ruby = <<~RUBY
      OVERRIDDEN_CONSTANT='trash' # leftovers:allow

      class MyConstant # leftovers:allow
      end
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to be_empty
    expect(collector.calls).to be_empty
  end

  it 'collects multiple inline comment allows' do
    ruby = <<~RUBY
      method_names = [
        :method_name_1,
        :method_name_1?,
        :method_name_1=,
        :method_name_1!,
      ]
      # leftovers:call method_name_1, method_name_1? method_name_1=, method_name_1!
      method_names.each { |n| send(n) }
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(
      :method_name_1, :method_name_1?, :method_name_1=, :method_name_1!,
      :each, :send
    )
  end

  it 'collects multiple inline comment allows for non alpha methods' do
    ruby = <<~RUBY
      # leftovers:call [] []= ** ! ~ +@ -@ * / % + - >> <<
      # leftovers:call & ^ | <= < > >= <=> == === != =~ !~
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect
    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(
      :[], :[]=, :**, :'!', :~, :+@, :-@, :*, :/, :%, :+, :-, :>>, :<<,
      :&, :^, :|, :<=, :<, :>, :>=, :<=>, :==, :===, :'!=', :=~, :!~
    )
  end

  it 'collects affixxed methods' do
    ruby = 'test_html'

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

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:test, :html, :test_html)
  end

  it 'collects array values' do
    ruby = 'flow(whatever, [:method_1, :method_2])'

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      ---
      rules:
        - name: flow
          calls:
            - argument: 2
    YML

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:flow, :whatever, :method_1, :method_2)
  end

  it 'collects matched keyword arguments' do
    ruby = 'flow(whatever, some_values: :method)'

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      ---
      rules:
        - name: flow
          calls:
            argument:
              has_prefix: some
    YML

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:flow, :whatever, :method)
  end

  it 'collects csend arguments' do
    ruby = 'nil&.flow(:argument)'

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      ---
      rules:
        - name: flow
          calls:
            argument: 1
    YML

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:flow, :argument)
  end

  it "doesn't collect position or keyword lvars" do
    ruby = <<~RUBY
      b = 1
      my_method(b, my_keyword: b)
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            argument: [1, my_keyword]
    YML

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:my_method)
  end

  it "doesn't collect rest kwargs" do
    ruby = <<~RUBY
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

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:my_method)
  end

  it 'collects constant assignment values' do
    ruby = <<~RUBY
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

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :STRING_TRANSFORMS
    expect(collector.calls).to contain_exactly(:downcase, :upcase)
  end

  it 'collects ivar assignment values' do
    ruby = <<~RUBY
      @string_transforms = %i{
        downcase
        upcase
      }
    RUBY

    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: '@string_transforms'
          calls:
            argument: 1
    YML

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :@string_transforms
    expect(collector.calls).to contain_exactly(:downcase, :upcase)
  end

  it 'collects constant assignment values with freeze' do
    ruby = <<~RUBY
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

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :STRING_TRANSFORMS
    expect(collector.calls).to contain_exactly(:downcase, :upcase, :freeze)
  end

  it 'collects constant hash assignment keys' do
    ruby = <<~RUBY
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

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :STRING_TRANSFORMS
    expect(collector.calls).to contain_exactly(:downcase, :upcase)
  end

  it 'collects constant hash assignment keys with freeze' do
    ruby = <<~RUBY
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

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :STRING_TRANSFORMS
    expect(collector.calls).to contain_exactly(:downcase, :upcase, :freeze)
  end

  it 'collects nested hash assignment values' do
    ruby = <<~RUBY
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

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :STRING_TRANSFORMS
    expect(collector.calls).to contain_exactly(:downcase, :upcase)
  end

  it 'reports syntax errors' do
    ruby = <<~RUBY
      true
      a(b,c
    RUBY

    collector = described_class.new(ruby, file)
    expect do
      collector.collect
    end.to output(
      "\e[2K\e[31mfoo.rb:3:0 SyntaxError: unexpected token $end\e[0m\n"
    ).to_stderr
  end

  it 'can call delete_after and delete_before on an empty string' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            delete_after: x
            delete_before: y
    YML

    ruby = <<~RUBY
      my_method('')
    RUBY

    collector = described_class.new(ruby, file)
    expect do
      collector.collect
    end.not_to raise_error

    expect(collector.calls).to contain_exactly(:my_method)
  end

  it 'can use from_argument with a suffix' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            add_suffix:
              from_argument: foo
              joiner: x
    YML

    ruby = <<~RUBY
      my_method(:bar, foo: :baz)
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:my_method, :barxbaz)
  end

  it 'can use from_argument with a non string value without crashing' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            add_suffix:
              from_argument: foo
              joiner: x
    YML

    ruby = <<~RUBY
      my_method(:bar, lol => :foo, foo: :baz)
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:my_method, :lol, :barxbaz)
  end

  it "can't use a dynamic value with just a joiner because it's just making a static value badly" do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            add_suffix:
              joiner: x
    YML

    ruby = <<~RUBY
      my_method(:bar, foo: :baz)
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:my_method, :bar)
  end

  it 'can call find has_argument with only value' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            if:
              has_argument:
                value: foo
    YML

    ruby = <<~RUBY
      my_method('baz', kw: 'qux')
      my_method('bar', kw: 'foo')
      my_method('lol')
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:bar, :my_method, :my_method, :my_method)
  end

  it 'can call find has_argument with only value types' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            if:
              has_argument:
                keyword: kw
                value:
                  type: [String, Symbol, Integer, Float]
    YML

    ruby = <<~RUBY
      my_method('baz', kw: 'qux')
      my_method('bar', kw: 1)
      my_method('lol', kw: no)
      my_method('foo', kw: 1.0)
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls)
      .to contain_exactly(:bar, :no, :baz, :foo, :my_method, :my_method, :my_method, :my_method)
  end

  it 'can call find has_argument with only value type' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            if:
              has_argument:
                keyword: kw
                value:
                  type: String
    YML

    ruby = <<~RUBY
      my_method('baz', kw: 'qux')
      my_method('bar', kw: 1)
      my_method('lol', kw: no)
      my_method('foo', kw: 1.0)
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls)
      .to contain_exactly(:no, :baz, :my_method, :my_method, :my_method, :my_method)
  end

  it 'can call find has_argument with only any of value' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            if:
              has_argument:
                value: [foo, bar]
    YML

    ruby = <<~RUBY
      my_method('baz', kw: 'bar')
      my_method('bar', kw: 'foo')
      my_method('lol', kw: 'qux')
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:bar, :baz, :my_method, :my_method, :my_method)
  end

  it 'can call find has_argument with string keys' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            if:
              has_argument: kw
    YML

    ruby = <<~RUBY
      my_method('bar', "kw" => 'foo')
      my_method('lol', 1 => true)
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:bar, :my_method, :my_method)
  end

  it 'can call find has_argument with an index' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            if:
              has_argument: 2
    YML

    ruby = <<~RUBY
      my_method('bar', 'foo')
      my_method('lol')
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:bar, :my_method, :my_method)
  end

  it 'can call find from_argument with an index' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: my_method
          calls:
            arguments: 1
            add_prefix:
              from_argument: 2
              joiner: '_'
    YML

    ruby = <<~RUBY
      my_method('bar', 'foo')
      my_method('lol')
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to be_empty
    expect(collector.calls).to contain_exactly(:foo_bar, :lol, :my_method, :my_method)
  end

  it 'can define a method based on a method name' do
    Leftovers.config << Leftovers::Config.new('test', content: <<~YML)
      rules:
        - name: def_my_method
          defines:
            itself: true
            delete_prefix: def_
    YML

    ruby = <<~RUBY
      def_my_method { |x| x.to_s }
    RUBY

    collector = described_class.new(ruby, file)
    collector.collect

    expect(collector.definitions).to have_names :my_method
    expect(collector.calls).to contain_exactly(:def_my_method, :to_s)
  end
end
