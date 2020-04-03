# frozen_string_literal: true

RSpec.describe Forgotten do
  it 'has a version number' do
    expect(Forgotten::VERSION).not_to be nil
  end

  describe '.forgotten' do
    around { |example| with_temp_dir { example.run } }
    before { described_class.reset }

    subject { described_class }

    it "doesn't care about using one of multiple simultaneous defined methods" do
      temp_file '.forgotten.yml', <<~YML
        gems: rails
      YML

      temp_file 'app/models/foo.rb', <<~RUBY
        attribute :foo

        def check_foo
          foo?
        end
      RUBY

      expect(subject.forgotten.map(&:name)).to contain_exactly :check_foo
      expect(subject.collector.definitions.map(&:name)).to contain_exactly(
        :foo, :foo?, :foo=, :check_foo
      )
      expect(subject.collector.calls).to contain_exactly(:attribute, :foo?)
    end

    it "doesn't think method calls in the same file are forgotten" do
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

      expect(subject.forgotten.map(&:name)).to contain_exactly :EmailActions

      expect(subject.collector.definitions.map(&:name)).to contain_exactly(:EmailActions, :initialize, :email_params_from_order, :address_params)
      expect(subject.collector.calls).to contain_exactly(:address_params, :email_params_from_order)
    end
  end
end
