RSpec.describe Forgotten do
  it "has a version number" do
    expect(Forgotten::VERSION).not_to be nil
  end

  describe '.forgotten' do
    around { |example| with_temp_dir { example.run } }
    before { described_class.reset }

    subject { described_class.forgotten }

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

      expect(subject.definitions).to contain_exactly starts_with(:EmailActions), starts_with(:initialize), starts_with(:email_params_from_order), starts_with(:address_params)
      expect(subject.calls).to contain_exactly(:address_params)
    end
  end
end
