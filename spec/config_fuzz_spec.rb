# frozen_string_literal: true

require 'support/config_fuzzer'

::RSpec.describe ::Leftovers::Config do
  next if ::ENV['COVERAGE']

  config_methods = described_class.new(:rails).public_methods - ::Class.new.new.public_methods

  before { ::Leftovers.reset }

  describe 'fuzzed config' do
    ::ENV.fetch('FUZZ_ITERATIONS', 10).to_i.times do |n|
      context "iteration #{n}" do
        let(:yaml) { ::Leftovers::ConfigLoader::Fuzzer.new(n).to_yaml }

        it do
          puts yaml

          expect do
            described_class.new('fuzz', content: yaml).tap do |c|
              config_methods.each { |method| c.send(method) }
            end
          end.not_to throw_symbol(:leftovers_exit)
        end
      end
    end
  end
end
