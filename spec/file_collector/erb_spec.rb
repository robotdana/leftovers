# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::FileCollector do
  subject(:collector) do
    collector = described_class.new(ruby, file)
    collector.collect
    collector
  end

  before { Leftovers.reset }

  after { Leftovers.reset }

  let(:path) { 'foo.erb' }
  let(:file) do
    f = Leftovers::File.new(Leftovers.pwd + path)
    allow(f).to receive(:read).and_return(erb)
    f
  end
  let(:erb) { '' }
  let(:ruby) { file.ruby }

  context 'with erb files' do
    let(:erb) do
      <<~ERB
        <a href="<%= whatever %>">label</a>'
      ERB
    end

    it do
      # the extra options are internal erb stuff and i don't mind
      expect(subject).to have_no_definitions
        .and(have_calls_including(:whatever))
        .and(have_calls_excluding(:a, :href, :label))
    end
  end

  context 'with erb files when newline trimmed' do
    let(:erb) do
      <<~ERB
        <%- if foo.present? -%>
          <a href="<%= foo %>">label</a>
        <%- end -%>
      ERB
    end

    it do
      # the extra options are internal erb stuff and i don't mind
      expect(subject).to have_no_definitions
        .and(have_calls_including(:foo, :present?))
        .and(have_calls_excluding(:a, :href, :label))
    end
  end
end
