# frozen-string-literal: true

require 'spec_helper'
require 'set'
require 'json_schemer'

RSpec.describe ::Leftovers::ConfigValidator do
  describe ::Leftovers::ConfigValidator::SCHEMA_HASH do
    it 'validates itself' do
      schema_schema = JSONSchemer.schema(Pathname.new(__dir__).join('support/schema_schema.json'))
      expect(schema_schema.valid?(described_class)).to be true
    end
  end

  describe 'gems' do
    ::Pathname.glob("#{__dir__}/../lib/config/*.yml").each do |config_path|
      gem = config_path.basename.sub_ext('').to_s
      it "can validate #{gem} default config" do
        config = ::Leftovers::Config.new(gem, path: config_path.to_s)
        expect { catch(:leftovers_exit) { config.dynamic } }.not_to output.to_stderr
      end
    end
  end
end
