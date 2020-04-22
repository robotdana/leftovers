# frozen_string_literal: true

RSpec.describe Leftovers::Config do
  describe '.rules' do
    describe 'gems' do
      files = Pathname.glob("#{__dir__}/../lib/config/*.yml")
      gems = files.map { |f| f.basename.sub_ext('').to_s }

      gems.each do |gem|
        it "can load #{gem} default config" do
          config = described_class.new(gem)
          expect { config.rules }.not_to raise_error
        end
      end
    end

    it 'can report config parse errors' do
      config = described_class.new('invalid', content: <<~YML)
        rules:
          - name: my_method
            - calls:
            arguments: 1
      YML
      expect do
        begin
          config.rules
        rescue SystemExit
          nil
        end
      end.to output(
        "\e[31mConfig SyntaxError: " \
        "(#{::File.expand_path('../lib/config/invalid.yml', __dir__)}): " \
        "did not find expected key while parsing a block mapping at line 2 column 5\e[0m\n"
      ).to_stderr
    end
  end
end
