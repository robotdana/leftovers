# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails gem' do
  subject(:collector) do
    collector = Leftovers::FileCollector.new(ruby, file)
    collector.collect
    collector
  end

  before do
    Leftovers.reset
    Leftovers.config << :rails
  end

  after { Leftovers.reset }

  let(:path) { 'foo.rb' }
  let(:file) { Leftovers::File.new(Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with method calls using a method that calls multiple methods' do
    let(:ruby) { 'before_action :method_one, :method_two' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:before_action, :method_one, :method_two)
    end
  end

  context 'with method calls using a method that calls multiple methods with keyword arguments' do
    let(:ruby) { 'skip_before_action :method_one, :method_two, if: :other_method?' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:skip_before_action, :method_one, :method_two, :other_method?)
    end
  end

  context 'with method calls using a method that calls multiple keyword arguments with splat' do
    let(:ruby) { 'skip_before_action :method_one, :method_two, **conditions' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:skip_before_action, :method_one, :method_two, :conditions)
    end
  end

  context 'with method calls passed to before_save if:' do
    let(:ruby) { 'before_save :do_a_thing, if: :thing_to_be_done?' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:before_save, :do_a_thing, :thing_to_be_done?)
    end
  end

  context 'with method calls passed in an array to a before_save if:' do
    let(:ruby) { 'before_save :do_a_thing, if: [:thing_to_be_done?, :another_thing?]' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:before_save, :do_a_thing, :thing_to_be_done?, :another_thing?)
    end
  end

  context 'with method calls in route values' do
    let(:ruby) { 'patch :thing, to: "users#logout"' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:patch, :thing, :UsersController, :logout)
    end
  end

  context 'with method calls in route root values' do
    let(:ruby) { 'root to: "home#index"' }

    it { is_expected.to have_no_definitions.and have_calls(:root, :HomeController, :index) }
  end

  context 'with method calls in namespaced route values' do
    let(:ruby) { 'get :admin, to: "administration/dashboard#index"' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:get, :Administration, :admin, :DashboardController, :index)
    end
  end

  context 'with scoped constant calls in class_name symbol keys' do
    let(:ruby) { 'has_many :whatevers, class_name: "Which::Ever"' }

    it do
      expect(subject).to have_definitions(
        :whatevers, :whatevers=, :whatever_ids, :whatever_ids=
      ).and have_calls(:has_many, :Which, :Ever)
    end
  end

  context 'with constantize' do
    let(:ruby) { '"Which::Ever".constantize' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:constantize, :Which, :Ever)
    end
  end

  context 'with constantize without a receiver' do
    let(:ruby) { 'constantize(:does_something_else)' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:constantize)
    end
  end

  context 'with hash key calls' do
    let(:ruby) { 'validates test: true, other: :bar, presence: true' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:TestValidator, :validates, :OtherValidator, :PresenceValidator)
    end
  end

  context 'with rest key calls' do
    let(:ruby) { 'validates test: true, presence: true, **validators' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:TestValidator, :validates, :PresenceValidator, :validators)
    end
  end

  context 'with non-restful route calls' do
    let(:ruby) { "get '/logout' => 'users#logout'" }

    it { is_expected.to have_no_definitions.and have_calls(:UsersController, :get, :logout) }
  end

  context 'with routes controller calls' do
    let(:ruby) do
      <<~RUBY
        controller :users do
          get :new
        end
      RUBY
    end

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:controller, :UsersController, :get, :new)
    end
  end

  context 'with routes resource calls' do
    let(:ruby) { 'resource :user' }

    it do
      expect(subject).to have_definitions.and have_calls(
        :resource, :UsersController, :UserController,
        :index, :new, :create, :edit, :update, :destroy
      )
    end
  end

  context 'with routes resource calls with except' do
    let(:ruby) { 'resource :user, except: :index' }

    it do
      expect(subject).to have_definitions.and have_calls(
        :resource, :UsersController, :UserController,
        :new, :create, :edit, :update, :destroy
      )
    end
  end

  context 'with routes resource calls with array except' do
    let(:ruby) { 'resource :user, except: [:index]' }

    it do
      expect(subject).to have_definitions.and have_calls(
        :resource, :UsersController, :UserController,
        :new, :create, :edit, :update, :destroy
      )
    end
  end

  context 'with routes resource calls with only' do
    let(:ruby) { 'resources :users, only: :index' }

    it do
      expect(subject).to have_definitions.and have_calls(
        :resources, :UsersController,
        :index
      )
    end
  end

  context 'with non-route resource calls' do
    let(:ruby) { 'Loader.resources' }

    it do
      expect(subject).to have_definitions.and have_calls(
        :resources, :Loader
      )
    end
  end

  context 'with routes resource calls with array only' do
    let(:ruby) { 'resources :users, only: [:index, :new]' }

    it do
      expect(subject).to have_definitions.and have_calls(
        :resources, :UsersController,
        :index, :new
      )
    end
  end

  context 'with delegation definitions and calls' do
    let(:ruby) { 'delegate :foo, to: :bar' }

    # it's not a definition because it doesn't create any new method names
    it { is_expected.to have_no_definitions.and have_calls(:delegate, :bar) }
  end

  context 'with delegation definitions and calls when prefix is defined' do
    let(:ruby) { 'delegate :foo, :few, prefix: :bar, to: :baz' }

    it do
      expect(subject).to have_definitions(:bar_foo, :bar_few)
        .and have_calls(:delegate, :baz, :foo, :few)
    end
  end

  context 'with delegation definitions and calls when prefix is true' do
    let(:ruby) { 'delegate :foo, :few, prefix: true, to: :bar' }

    it do
      expect(subject).to have_definitions(:bar_foo, :bar_few)
        .and have_calls(:delegate, :bar, :foo, :few)
    end
  end

  context 'with attribute assignment args' do
    let(:ruby) { 'User.new(first_name: "Jane", last_name: "Smith")' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:User, :new, :first_name=, :last_name=, :allocate, :initialize)
    end
  end

  context 'with bang methods' do
    let(:ruby) { 'User.create!' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:User, :create!)
    end
  end

  context 'with basic permit args' do
    let(:ruby) { 'permit(:first_name, :last_name)' }

    it { is_expected.to have_no_definitions.and have_calls(:permit, :first_name=, :last_name=) }
  end

  context 'with hash permit args' do
    let(:ruby) { 'permit(names: [:first_name, :last_name], age: :years)' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(
          :permit, :names=, :first_name=, :last_name=, :age=, :years=
        )
    end
  end

  context 'with deep permit args' do
    let(:ruby) { <<~RUBY }
      permit person_attributes: { names: [:first_name, :last_name, { deep: :hash}], age: :years }
    RUBY

    it do
      expect(subject).to have_no_definitions
        .and have_calls(
          :permit, :names=, :first_name=, :last_name=,
          :age=, :years=, :person_attributes=, :deep=, :hash=
        )
    end
  end

  context 'with generators with private messages' do
    let(:path) { 'lib/generators/initializer_generator.rb' }
    let(:ruby) do
      <<~RUBY
        class InitializerGenerator < Rails::Generators::Base
          def create_initializer_file
            create_file "config/initializers/initializer.rb", "# content"
          end

          private

          def leftover_support_method
            create_file 'forgotten.yml'
          end
        end
      RUBY
    end

    it do
      # keep drops things from definitions
      expect(subject).to have_definitions(:InitializerGenerator, :leftover_support_method)
        .and have_calls(:Rails, :Generators, :Base, :create_file, :private)
    end
  end

  context 'with routes scope' do
    let(:ruby) do
      <<~RUBY
        Rails.application.routes.draw do
          scope '/whatever', module: :whichever
        end
      RUBY
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(
          :Rails, :application, :routes, :draw, :scope, :Whichever
        ))
    end
  end

  context 'with AR scope' do
    let(:ruby) do
      <<~RUBY
        class User < ApplicationRecord
          scope :whatever, -> { order(:whichever) }
        end
      RUBY
    end

    it do
      expect(subject).to have_definitions(:User, :whatever)
        .and have_calls(:ApplicationRecord, :lambda, :scope, :order)
    end
  end

  context 'with scope with 1 argument' do
    let(:ruby) { "scope 'some other thing'" }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:scope)
    end
  end

  context 'with validation calls' do
    let(:ruby) { 'validate :validator_method_name, if: :condition?' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:validate, :validator_method_name, :condition?)
    end
  end

  context 'with validations calls inclusion method' do
    let(:ruby) { 'validates :name, inclusion: :inclusion_method, if: :condition?' }

    it do
      expect(subject).to have_no_definitions.and have_calls(
        :validates, :name, :inclusion_method, :condition?,
        :InclusionValidator
      )
    end
  end

  context 'with validations calls non-symbol validator' do
    let(:ruby) { 'validates :name, @ivar_key => :inclusion_method, if: :condition?' }

    it do
      expect(subject).to have_no_definitions.and have_calls(
        :validates, :name, :condition?, :@ivar_key
      )
    end
  end

  context 'with validations calls with inclusion hash' do
    let(:ruby) { 'validates :name, inclusion: { in: :inclusion_method }, if: :condition?' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(
          :validates, :name, :inclusion_method, :condition?,
          :InclusionValidator
        )
    end
  end

  context "with eval'd bit" do
    let(:ruby) do
      <<~RUBY
        assert_changes 'Status.all_good?' do
          post :create, params: { status: { ok: false } }
        end
      RUBY
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:assert_changes, :Status, :all_good?, :post, :create))
    end
  end

  context 'with store' do
    let(:ruby) do
      <<~RUBY
        class User < ActiveRecord::Base
          store :settings, accessors: [ :color, :homepage ], coder: JSON
          store :parent, accessors: [ :name ], coder: JSON, prefix: true
          store :spouse, accessors: [ :name ], coder: JSON, prefix: :partner
          store :settings, accessors: [ :two_factor_auth ], suffix: true
          store :settings, accessors: [ :login_retry ], suffix: :config
          store :settings, accessors: [ :database ], prefix: :app, suffix: :config
          store :settings, accessors: [ :username ], prefix: :global, suffix: true
        end
      RUBY
    end

    it do
      expect(subject).to have_definitions(
        :User,
        :color, :color=, :color_changed?, :color_was, :color_change,
        :homepage, :homepage=, :homepage_changed?, :homepage_was, :homepage_change,
        :parent_name, :parent_name=, :parent_name_changed?, :parent_name_was, :parent_name_change,
        :partner_name, :partner_name=, :partner_name_changed?, :partner_name_was,
        :partner_name_change,
        :two_factor_auth_settings, :two_factor_auth_settings=, :two_factor_auth_settings_changed?,
        :two_factor_auth_settings_was, :two_factor_auth_settings_change,
        :login_retry_config, :login_retry_config=, :login_retry_config_changed?,
        :login_retry_config_was, :login_retry_config_change,
        :app_database_config, :app_database_config=, :app_database_config_changed?,
        :app_database_config_was, :app_database_config_change,
        :global_username_settings, :global_username_settings=, :global_username_settings_changed?,
        :global_username_settings_was, :global_username_settings_change
      ).and(have_calls(:store, :ActiveRecord, :Base, :JSON))
    end
  end

  context 'with store_accessor' do
    let(:ruby) do
      <<~RUBY
        class User < ActiveRecord::Base
          store_accessor :settings, :color, :homepage
          store_accessor :parent, :name, prefix: true
          store_accessor :spouse, :name, prefix: :partner
          store_accessor :settings, :two_factor_auth, suffix: true
          store_accessor :settings, :login_retry, suffix: :config
          store_accessor :settings, :database, prefix: :app, suffix: :config
          store_accessor :settings, :username, prefix: :global, suffix: true
          store_accessor()
        end
      RUBY
    end

    it do
      expect(subject).to have_definitions(
        :User,
        :color, :color=, :color_changed?, :color_was, :color_change,
        :homepage, :homepage=, :homepage_changed?, :homepage_was, :homepage_change,
        :parent_name, :parent_name=, :parent_name_changed?, :parent_name_was, :parent_name_change,
        :partner_name, :partner_name=, :partner_name_changed?, :partner_name_was,
        :partner_name_change,
        :two_factor_auth_settings, :two_factor_auth_settings=, :two_factor_auth_settings_changed?,
        :two_factor_auth_settings_was, :two_factor_auth_settings_change,
        :login_retry_config, :login_retry_config=, :login_retry_config_changed?,
        :login_retry_config_was, :login_retry_config_change,
        :app_database_config, :app_database_config=, :app_database_config_changed?,
        :app_database_config_was, :app_database_config_change,
        :global_username_settings, :global_username_settings=, :global_username_settings_changed?,
        :global_username_settings_was, :global_username_settings_change
      ).and(have_calls(:store_accessor, :ActiveRecord, :Base))
    end
  end
end
