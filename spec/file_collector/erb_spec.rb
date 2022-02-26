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
    with_temp_dir
  end

  after { Leftovers.reset }

  let(:path) { 'foo.erb' }
  let(:file) do
    temp_file(path, erb)
    Leftovers::File.new(Leftovers.pwd + path)
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
      expect(subject).to have_no_definitions
        .and(have_calls_including(:whatever))
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
      expect(subject).to have_no_definitions
        .and(have_calls(:foo, :present?))
    end
  end

  context 'with erb files when block begins' do
    let(:erb) do
      <<~ERB
        <% bar do %>
          <a href="<%= foo %>">label</a>
        <% end %>
      ERB
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls(:foo, :bar))
    end
  end

  context 'with erb files when comments' do
    let(:erb) do
      <<~ERB
        <% #Comment %>
        <% if query? %>
          <%= call %>
        <% end %>
      ERB
    end

    it do
      expect(subject).to have_no_definitions.and(have_calls(:query?, :call))
    end
  end

  context 'with invalid? erb file' do
    # erb just interprets this as literal text
    let(:erb) do
      <<~ERB
        <%= true if query?
      ERB
    end

    it do
      expect(subject).to have_no_definitions.and(have_no_calls)
    end
  end
end
