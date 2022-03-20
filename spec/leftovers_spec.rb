# frozen_string_literal: true

::RSpec.describe ::Leftovers do
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
      described_class.try_require('not here')

      described_class.stdout
      described_class.stderr
      described_class.config

      # ::Leftovers.pwd is stubbed by with_temp_dir
      expect(
        subject.instance_variables
      ).to contain_exactly(
        *(::Leftovers::MEMOIZED_IVARS - [:@pwd])
      )

      described_class.reset

      expect(described_class.instance_variable_defined?(:@stdout)).not_to be true
      expect(described_class.instance_variable_defined?(:@stderr)).not_to be true
      expect(described_class.instance_variable_defined?(:@config)).not_to be true
    end
  end
end
