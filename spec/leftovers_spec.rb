# frozen_string_literal: true

::RSpec.describe ::Leftovers do
  describe 'version' do
    changelog = ::File.read(::File.expand_path('../CHANGELOG.md', __dir__))
    changelog_version = changelog.match(/^# v([\d.]+)$/)&.captures&.first

    it "has the version number: #{changelog_version}, matching the changelog" do
      expect(described_class::VERSION).to eq changelog_version
    end
  end

  describe '.reset' do
    it 'unmemoizes everything' do
      described_class.try_require('not here')

      described_class.stdout
      described_class.stderr
      described_class.config
      described_class.pwd

      expect(
        subject.instance_variables
      ).to contain_exactly(
        *::Leftovers::MEMOIZED_IVARS
      )

      described_class.reset

      expect(subject.instance_variables).to be_empty
    end
  end
end
