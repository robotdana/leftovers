# frozen_string_literal: true

RSpec.describe Leftovers do
  before { described_class.reset }

  after { described_class.reset }

  it 'has a version number' do
    expect(Leftovers::VERSION).not_to be nil
  end

  describe '.leftovers' do
    subject { described_class }

    around { |example| with_temp_dir { example.run } }

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

      allow(subject).to receive(:stdout).and_return(StringIO.new) # rubocop:disable RSpec/SubjectStub

      expect(subject.leftovers).to have_names :check_foo
      expect(subject.collector.definitions).to have_names(
        :foo, :foo?, :foo=, :check_foo
      )
      expect(subject.collector.calls).to contain_exactly(:attribute, :foo?)
    end

    it "doesn't think method calls in the same file are leftovers" do
      temp_file 'foo.rb', <<~RUBY
        class Actions
          def initialize(params)
            prepare_params(params)
          end

          def prepare_params(params)
            {
              attributes: sub_params(params)
            }
          end

          def sub_params(params)
            true
          end
        end
      RUBY

      expect(subject.leftovers).to have_names :Actions
      expect(subject.collector.definitions)
        .to have_names(:Actions, :initialize, :prepare_params, :sub_params)

      expect(subject.collector.calls).to contain_exactly(:sub_params, :prepare_params)
    end
  end
end
