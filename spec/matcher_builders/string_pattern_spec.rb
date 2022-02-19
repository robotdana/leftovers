# frozen_string_literal: true

RSpec.describe ::Leftovers::MatcherBuilders::StringPattern do
  describe '.build' do
    it 'returns nil when given nothing' do
      expect(described_class.build).to be_nil
    end

    it 'returns an anchored regex when given match' do
      expect(described_class.build(match: 'a')).to match 'a'
      expect(described_class.build(match: 'a')).not_to match 'aa'
      expect(described_class.build(match: 'a*')).to match 'aa'
    end

    it 'matches exact strings when given has_prefix' do
      expect(described_class.build(has_prefix: 'a')).to match 'ax'
      expect(described_class.build(has_prefix: '[a]')).not_to match 'ax'
      expect(described_class.build(has_prefix: '[a]')).to match '[a]x'
    end

    it 'matches exact strings when given has_suffix' do
      expect(described_class.build(has_suffix: 'x')).to match 'ax'
      expect(described_class.build(has_suffix: '[x]')).not_to match 'ax'
      expect(described_class.build(has_suffix: '[x]')).to match 'a[x]'
    end

    it 'matches strings when given has_prefix and has_suffix' do
      expect(described_class.build(has_prefix: 'a', has_suffix: 'x')).to match 'ax'
      expect(described_class.build(has_prefix: '[a]', has_suffix: '[x]')).not_to match 'ax'
      expect(described_class.build(has_prefix: '[a]', has_suffix: '[x]')).to match '[a][x]'
    end

    it 'can overlap the match for has_prefix and has_suffix' do
      expect(described_class.build(has_prefix: 'a_', has_suffix: '_x')).to match 'a_x'
    end

    it 'can combine match and has_prefix' do
      expect(described_class.build(match: '[a-z]*', has_prefix: 'a')).to match 'ax'
      expect(described_class.build(match: '[a-z]*', has_prefix: 'a')).not_to match 'a_x'
    end

    it 'can combine match and has_suffix' do
      expect(described_class.build(match: '[a-z]*', has_suffix: 'x')).to match 'ax'
      expect(described_class.build(match: '[a-z]*', has_suffix: 'x')).not_to match 'a_x'
    end

    it 'can combine match and has_prefix and has_suffix' do
      expect(described_class.build(match: '[a-z]*', has_prefix: 'l', has_suffix: 'x'))
        .to match 'lax'
      expect(described_class.build(match: '[a-z]*', has_prefix: 'l', has_suffix: 'x'))
        .not_to match 'l a x'
    end
  end
end
