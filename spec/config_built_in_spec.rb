# frozen_string_literal: true

::RSpec.describe ::Leftovers::Config do
  config_methods = described_class.new(:rails).public_methods - ::Class.new.new.public_methods

  describe 'built in config' do
    files = ::Pathname.glob("#{__dir__}/../lib/config/*.yml")
    gems = files.map { |f| f.basename.sub_ext('').to_s }

    gems.each do |gem|
      it gem do
        expect do
          catch(:leftovers_exit) do
            described_class.new(gem).tap do |c|
              config_methods.each { |method| c.send(method) }
            end
          end
        end.not_to output.to_stderr
      end
    end

    context 'when merged' do
      merged_config_methods = ::Leftovers.config.public_methods
      merged_config_methods -= ::Class.new.new.public_methods
      merged_config_methods -= %i{<<}

      it 'can build the voltron (sorted)' do
        expect do
          catch(:leftovers_exit) do
            gems.sort.each { |gem| ::Leftovers.config << gem }
            merged_config_methods.each { |method| ::Leftovers.config.send(method) }
          end
        end.not_to output.to_stderr
      end

      10.times do |iteration|
        next if ::ENV['COVERAGE']

        it "can build the voltron (shuffle #{iteration})" do
          srand ::RSpec.configuration.seed + iteration

          expect do
            catch(:leftovers_exit) do
              gems.shuffle.each { |gem| ::Leftovers.config << gem }
              merged_config_methods.each { |method| ::Leftovers.config.send(method) }
            end
          end.not_to output.to_stderr
        end
      end
    end
  end
end
