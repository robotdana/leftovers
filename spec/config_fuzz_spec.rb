# frozen_string_literal: true

require 'support/config_fuzzer'

RSpec.describe Leftovers::Config do
  next if ENV['COVERAGE']

  config_methods = described_class.new(:rails).public_methods - Class.new.new.public_methods

  before { Leftovers.reset }

  describe 'fuzzed config' do
    ENV.fetch('FUZZ_ITERATIONS', 1000).to_i.times do |n|
      context "iteration #{n}" do
        let(:yaml) { ConfigFuzzer.new(n).to_yaml }

        it do
          puts yaml

          expect do
            catch(:leftovers_exit) do
              described_class.new('fuzz', content: yaml).tap do |c|
                config_methods.each { |method| c.send(method) }
              end
            end
          end.not_to(output.to_stderr)
        end
      end
    end
  end
end
