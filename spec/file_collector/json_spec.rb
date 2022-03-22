# frozen_string_literal: true

require 'spec_helper'

::RSpec.describe ::Leftovers::Precompilers::JSON do
  subject(:collector) do
    collector = ::Leftovers::FileCollector.new(ruby, file)
    collector.collect
    collector
  end

  let(:path) { 'foo.json' }
  let(:file) do
    ::Leftovers::File.new(::Leftovers.pwd + path)
      .tap { |f| allow(f).to receive_messages(read: json) }
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
      expect { subject }.to print_warning(match(
        /\AJSON::ParserError: foo.json (\d+: )?unexpected token at ''\n\z/
      ))
      expect(subject).to have_no_definitions.and(have_no_calls)
    end
  end
end
