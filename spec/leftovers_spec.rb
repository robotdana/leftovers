# frozen_string_literal: true

RSpec.describe Leftovers do
  before { described_class.reset }

  after { described_class.reset }

  describe 'version' do
    changelog = ::File.read(::File.expand_path('../CHANGELOG.md', __dir__))
    changelog_version = changelog.match(/^# v([\d.]+)$/)&.captures&.first

    it "has the version number: #{changelog_version}, matching the changelog" do
      expect(described_class::VERSION).to eq changelog_version
    end
  end

  describe '.reset' do
    before { with_temp_dir }

    it 'unmemoizes everything' do
      described_class.run
      described_class.try_require('not here')

      original_stdout = described_class.stdout
      original_stderr = described_class.stderr
      original_config = described_class.config
      original_collector = described_class.collector
      original_reporter = described_class.reporter
      original_leftovers = described_class.leftovers
      original_parallel = described_class.parallel = true
      original_progress = described_class.progress = true

      # Leftovers.pwd is stubbed by with_temp_dir
      expect(
        subject.instance_variables
      ).to contain_exactly(
        *(::Leftovers::MEMOIZED_IVARS - [:@pwd])
      )

      described_class.reset

      expect(described_class.stdout).not_to eq original_stdout
      expect(described_class.stderr).not_to eq original_stderr
      expect(described_class.config).not_to eq original_config
      expect(described_class.collector).not_to eq original_collector
      expect(described_class.reporter).not_to eq original_reporter
      expect(described_class.leftovers).not_to be original_leftovers
      expect(described_class.parallel).not_to eq original_parallel
      expect(described_class.progress).not_to eq original_progress
    end
  end

  describe '.leftovers' do
    subject { described_class }

    before { with_temp_dir }

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

      expect(subject.leftovers.flat_map(&:names)).to eq [:check_foo]
      expect(subject.collector).to have_definitions(
        :foo, :foo?, :foo=, :check_foo
      ).and(have_calls(:attribute, :foo?))
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

      expect(subject.leftovers.flat_map(&:names)).to eq [:Actions]
      expect(subject.collector).to have_definitions(
        :Actions, :prepare_params, :sub_params
      ).and(have_calls(:sub_params, :prepare_params))
    end
  end
end
