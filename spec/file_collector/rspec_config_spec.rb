# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::FileCollector do
  subject(:collector) do
    collector = described_class.new(ruby, file)
    collector.collect
    collector
  end

  before do
    Leftovers.reset
    Leftovers.config << :rspec

    with_temp_dir
  end

  after { Leftovers.reset }

  let(:path) { temp_file 'spec/file_spec.rb' } # the file needs to exist
  let(:file) { Leftovers::File.new(Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with method calls using be_' do
    let(:ruby) { 'expect(array).to be_empty' }

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:expect, :array, :to, :empty?, :be_empty))
    end
  end
end
