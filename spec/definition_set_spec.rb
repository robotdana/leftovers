# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::DefinitionSet do
  describe 'full_name' do
    let(:method_node) { Leftovers::Parser.parse_with_comments('foo()').first }

    it 'has multiple names' do
      ds = described_class.new(%w{one two}, method_node: method_node)

      expect(ds.full_name).to eq 'one, two'
    end
  end
end
