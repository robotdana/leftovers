# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::JSON do
  subject(:collector) do
    collector = Leftovers::FileCollector.new(ruby, file)
    collector.collect
    collector
  end

  before do
    Leftovers.reset
    with_temp_dir
  end

  after { Leftovers.reset }

  let(:path) { 'foo.json' }
  let(:file) do
    temp_file(path, json)

    Leftovers::File.new(Leftovers.pwd + path).tap do |f|
      allow(f).to receive(:json?).and_return(true)
    end
  end
  let(:json) { '' }
  let(:ruby) { file.ruby }

  context 'with invalid json files' do
    let(:json) do
      <<~JSON
        [
      JSON
    end

    it 'outputs an error and collects nothing' do
      expect { subject }.to output(match(
        /JSON::ParserError: \(foo.json\): \d+: unexpected token at ''/
      )).to_stderr
      expect(subject).to have_no_definitions.and(have_no_calls)
    end
  end
end
