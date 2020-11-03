# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::DefinitionSet do
  let(:method_node) { Leftovers::Parser.parse_with_comments('foo()').first }

  describe 'to_s' do
    it 'has multiple names' do
      ds = described_class.new(%w{one two}, method_node: method_node)

      expect(ds.to_s).to eq 'one, two'
    end
  end

  describe '<=>' do
    it 'can sort identical items' do
      ds1 = described_class.new(%w{one two}, method_node: method_node)
      ds2 = described_class.new(%w{one two}, method_node: method_node)

      expect(ds1.location_s <=> ds2.location_s).to be 0
    end

    it 'can further in the line later' do
      method_nodes = Leftovers::Parser.parse_with_comments('foo(); bar()').first.children
      ds1 = described_class.new(%w{one two}, method_node: method_nodes[1])
      ds2 = described_class.new(%w{one two}, method_node: method_nodes[0])

      expect(ds1.location_s <=> ds2.location_s).to be 1
    end

    it 'can earlier in the line earlier' do
      method_nodes = Leftovers::Parser.parse_with_comments('foo(); bar()').first.children
      ds1 = described_class.new(%w{one two}, method_node: method_nodes[0])
      ds2 = described_class.new(%w{one two}, method_node: method_nodes[1])

      expect(ds1.location_s <=> ds2.location_s).to be(-1)
    end
  end
end
