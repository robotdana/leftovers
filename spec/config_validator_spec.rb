# frozen-string-literal: true

require 'spec_helper'

require_relative '../lib/leftovers/config_validator'

RSpec.describe ::Leftovers::ConfigValidator do
  describe ::Leftovers::ConfigValidator::SCHEMA_HASH do
    it 'validates itself' do
      schema_schema = JSONSchemer.schema(Pathname.new(__dir__).join('support/schema_schema.json'))
      expect(schema_schema.valid?(described_class)).to be true
    end
  end

  describe ::Leftovers::ConfigValidator::AVAILABLE_GEMS do
    it 'lists available gems' do
      files = Pathname.glob("#{__dir__}/../lib/config/*.yml")
      gems = files.map { |f| f.basename.sub_ext('').to_s }.sort

      expect(described_class).to eq(gems)
    end
  end

  describe 'gems' do
    ::Leftovers::ConfigValidator::AVAILABLE_GEMS.each do |gem|
      it "can validate #{gem} default config" do
        config = ::Leftovers::Config.new(gem)
        expect { catch(:leftovers_exit) { config.rules } }.not_to output.to_stderr
      end
    end
  end
end
