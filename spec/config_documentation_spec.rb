# frozen_string_literal: true

require 'fast_ignore'

::RSpec.describe ::Leftovers::Config do
  config_methods = described_class.new(:rails).public_methods - ::Class.new.new.public_methods

  describe 'config in documentation' do
    files = ::FastIgnore.new(include_rules: ['*.md', '!CHANGELOG.md', '!vendor'])
    files.each do |file|
      file = ::Leftovers::File.new(file)
      file.read.scan(/(?<=```yml\n)[^`]*(?=\n```\n)/).each.with_index(1) do |yaml, index|
        it "#{file.relative_path} example #{index}\n\e[0m#{yaml}" do
          expect do
            described_class.new('docs', path: "#{file}:#{index}", content: yaml).tap do |c|
              config_methods.each { |method| c.send(method) }
            end
          end.not_to output.to_stderr
        end
      end
    end
  end
end
