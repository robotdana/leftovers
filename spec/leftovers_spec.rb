# frozen_string_literal: true

RSpec.describe Leftovers do
  it 'has a version number' do
    expect(Leftovers::VERSION).not_to be nil
  end

  describe '.config.rules' do
    around { |example| with_temp_dir { example.run } }
    before { described_class.reset }
    it 'can load all default config' do
      files = Pathname.glob("#{__dir__}/../lib/config/*.yml")
      files = files.map { |f| f.basename.sub_ext('').to_s }

      temp_file '.leftovers.yml', <<~YML
        gems: #{files.inspect}
      YML

      Leftovers.config.include_paths
      Leftovers.config.exclude_paths
      Leftovers.config.test_paths
      Leftovers.config.rules
    end
  end

  describe '.leftovers' do
    around { |example| with_temp_dir { example.run } }
    before { described_class.reset }

    subject { described_class }

    it "doesn't care about using one of multiple simultaneous defined methods" do
      temp_file '.leftovers.yml', <<~YML
        gems: rails
      YML

      temp_file 'app/models/foo.rb', <<~RUBY
        attribute :foo

        def check_foo
          foo?
        end
      RUBY

      expect(subject.leftovers.map(&:name)).to contain_exactly :check_foo
      expect(subject.collector.definitions.map(&:name)).to contain_exactly(
        :foo, :foo?, :foo=, :check_foo
      )
      expect(subject.collector.calls).to contain_exactly(:attribute, :foo?)
    end

    it "doesn't think method calls in the same file are leftovers" do
      temp_file 'foo.rb', <<~RUBY
        class EmailActions
          def initialize(order_params)
            email_params_from_order(order_params)
          end

          def email_params_from_order(order_params)
            {
              address_attributes: address_params(order_params)
            }
          end

          def address_params(order_params)
            true
          end
        end
      RUBY

      expect(subject.leftovers.map(&:name)).to contain_exactly :EmailActions
      expect(subject.collector.definitions.map(&:name)).to contain_exactly(:EmailActions, :initialize, :email_params_from_order, :address_params)

      expect(subject.collector.calls).to contain_exactly(:address_params, :email_params_from_order)
    end
  end
end
