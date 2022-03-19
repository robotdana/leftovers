# frozen_string_literal: true

require 'spec_helper'

::RSpec.describe ::Leftovers::DefinitionSet do
  describe 'to_s' do
    it 'has multiple names' do
      ds = described_class.new(%w{one two})

      expect(ds.to_s).to eq 'one, two'
    end
  end
end
