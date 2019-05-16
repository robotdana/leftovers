RSpec.describe Forgotten do
  it "has a version number" do
    expect(Forgotten::VERSION).not_to be nil
  end

  describe '.forgotten' do
    around { |example| with_temp_dir { example.run } }
    before { described_class.reset }

    subject { described_class.collector }

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

      subject.collect

      expect(subject.definitions).to contain_exactly starting_with(:EmailActions), starting_with(:initialize), starting_with(:email_params_from_order), starting_with(:address_params)
      expect(subject.calls).to contain_exactly(:address_params, :email_params_from_order)
    end
  end
end
