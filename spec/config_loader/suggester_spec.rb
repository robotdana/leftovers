# frozen_string_literal: true

require 'did_you_mean'

RSpec.describe ::Leftovers::ConfigLoader::Suggester do
  subject { described_class.new(%w{cat bar dog}) }

  describe '#suggest' do
    it 'returns spelling suggestions' do
      expect(subject.suggest('car')).to eq %w{cat bar}
    end

    it "returns all options if DidYouMean isn't loaded" do
      hide_const('DidYouMean')

      expect(subject.suggest('car')).to eq %w{cat bar dog}
    end
  end
end
