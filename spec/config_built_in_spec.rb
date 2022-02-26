# frozen_string_literal: true

require 'support/config_fuzzer'

RSpec.describe Leftovers::Config do
  config_methods = described_class.new(:rails).public_methods - Class.new.new.public_methods

  before { Leftovers.reset }

  describe 'built in config' do
    files = Pathname.glob("#{__dir__}/../lib/config/*.yml")
    gems = files.map { |f| f.basename.sub_ext('').to_s }

    gems.each do |gem|
      it gem do
        expect do
          described_class.new(gem).tap do |c|
            config_methods.each { |method| c.send(method) }
          end
        end.not_to throw_symbol(:leftovers_exit)
      end
    end
  end
end
