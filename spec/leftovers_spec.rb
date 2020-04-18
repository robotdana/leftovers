# frozen_string_literal: true

RSpec.describe Leftovers do
  it 'has a version number' do
    expect(Leftovers::VERSION).not_to be nil
  end

  describe '.config.rules' do
    around { |example| with_temp_dir { example.run } }

    before { described_class.reset }

    after { described_class.reset }

    it 'can load all default config' do
      files = Pathname.glob("#{__dir__}/../lib/config/*.yml")
      files = files.map { |f| f.basename.sub_ext('').to_s }

      temp_file '.leftovers.yml', <<~YML
        gems: #{files.inspect}
      YML

      described_class.config.include_paths
      described_class.config.exclude_paths
      described_class.config.test_paths
      described_class.config.rules
    end
  end

  describe '.leftovers' do
    subject { described_class }

    around { |example| with_temp_dir { example.run } }

    before { described_class.reset }

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
