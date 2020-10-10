# frozen_string_literal: true

# :nocov:
using ::Leftovers::SetCaseEq if defined?(::Leftovers::SetCaseEq)
# :nocov:
RSpec::Matchers.define :case_eq do |expected|
  match do |actual|
    actual === expected
  end
end
require_relative '../lib/leftovers/builders/name_matcher'
RSpec.describe Leftovers::Builders::NameMatcher do
  subject { described_class.build(value, default) }

  let(:default) { true }

  context 'with nil value' do
    let(:value) { nil }

    it 'always matches nothing' do
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :whichever
    end
  end

  context 'with nil value and false default' do
    let(:value) { nil }
    let(:default) { false }

    it 'never matches nothing' do
      expect(subject).not_to case_eq :whatever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with empty array value' do
    let(:value) { [] }

    it 'always matches nothing' do
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :whichever
    end
  end

  context 'with nil array value' do
    let(:value) { [nil] }

    it 'always matches nothing' do
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :whichever
    end
  end

  context 'with single string value' do
    let(:value) { 'what' }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :whatever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with single string array value' do
    let(:value) { ['what'] }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :whatever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with nil and single string array value' do
    let(:value) { [nil, 'what'] }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :whatever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with string array value' do
    let(:value) { %w{what when} }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).to case_eq :when
      expect(subject).not_to case_eq :whatever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with prefix match value' do
    let(:value) { { has_prefix: 'what' } }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :whatever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with array prefix match value' do
    let(:value) { [{ has_prefix: 'what' }] }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :whatever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with multiple prefix match value' do
    let(:value) { [{ has_prefix: 'what' }, { has_prefix: 'which' }] }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :whichever
    end
  end

  context 'with suffix match value' do
    let(:value) { { has_suffix: 'ever' } }

    it 'always matches exact value' do
      expect(subject).not_to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :whichever
    end
  end

  context 'with array suffix match value' do
    let(:value) { [{ has_suffix: 'ever' }] }

    it 'always matches exact value' do
      expect(subject).not_to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :ever
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :whichever
    end
  end

  context 'with multiple suffix match value' do
    let(:value) { [{ has_suffix: 'ever' }, { has_suffix: 'what' }] }

    it 'always matches exact value' do
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :whichever
    end
  end

  context 'with prefix and suffix for the same value' do
    let(:value) { { has_suffix: 'ever', has_prefix: 'what' } }

    it 'always matches exact value' do
      expect(subject).not_to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :what_ever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with prefix and suffix for the same value in an array' do
    let(:value) { [{ has_suffix: 'ever', has_prefix: 'what' }] }

    it 'always matches exact value' do
      expect(subject).not_to case_eq :what
      expect(subject).not_to case_eq :when
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :what_ever
      expect(subject).not_to case_eq :whichever
    end
  end

  context 'with match' do
    let(:value) { { match: 'column\d+' } }

    it 'always matches exact value' do
      expect(subject).not_to case_eq :column_one
      expect(subject).not_to case_eq :column
      expect(subject).to case_eq :column1
      expect(subject).to case_eq :column11
    end
  end

  context 'with matches' do
    let(:value) { { matches: 'column\d+' } }

    it 'always matches exact value' do
      expect(subject).not_to case_eq :column_one
      expect(subject).not_to case_eq :column
      expect(subject).to case_eq :column1
      expect(subject).to case_eq :column11
    end
  end

  context 'with a combination' do
    let(:value) { ['which', nil, { has_prefix: 'what' }, { matches: 'column\d+' }] }

    it 'always matches exact value' do
      expect(subject).not_to case_eq :column_one
      expect(subject).not_to case_eq :column
      expect(subject).to case_eq :column1
      expect(subject).to case_eq :column11
      expect(subject).to case_eq :whatever
      expect(subject).to case_eq :what
      expect(subject).not_to case_eq :whichever
      expect(subject).to case_eq :which
    end
  end

  describe 'nesting' do
    subject { described_class.build([base, 'new_value']) }

    let(:base) { described_class.build(value, default) }

    context 'with nil value' do
      let(:value) { nil }

      it 'only matches new_value' do
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
        expect(subject).to case_eq :new_value
      end
    end

    context 'with nil value and false default' do
      let(:value) { nil }
      let(:default) { false }

      it 'only matches new_value' do
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
        expect(subject).to case_eq :new_value
      end
    end

    context 'with empty array value' do
      let(:value) { [] }

      it 'only matches new_value' do
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
        expect(subject).to case_eq :new_value
      end
    end

    context 'with nil array value' do
      let(:value) { [nil] }

      it 'only matches new_value' do
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
        expect(subject).to case_eq :new_value
      end
    end

    context 'with single string value' do
      let(:value) { 'what' }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with single string array value' do
      let(:value) { ['what'] }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with nil and single string array value' do
      let(:value) { [nil, 'what'] }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with string array value' do
      let(:value) { %w{what when} }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :when
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :whatever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with prefix match value' do
      let(:value) { { has_prefix: 'what' } }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :whatever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with array prefix match value' do
      let(:value) { [{ has_prefix: 'what' }] }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :whatever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with multiple prefix match value' do
      let(:value) { [{ has_prefix: 'what' }, { has_prefix: 'which' }] }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :whichever
      end
    end

    context 'with suffix match value' do
      let(:value) { { has_suffix: 'ever' } }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :whichever
      end
    end

    context 'with array suffix match value' do
      let(:value) { [{ has_suffix: 'ever' }] }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :ever
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :whichever
      end
    end

    context 'with multiple suffix match value' do
      let(:value) { [{ has_suffix: 'ever' }, { has_suffix: 'what' }] }

      it 'always matches exact value' do
        expect(subject).to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :whichever
      end
    end

    context 'with prefix and suffix for the same value' do
      let(:value) { { has_suffix: 'ever', has_prefix: 'what' } }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :what_ever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with prefix and suffix for the same value in an array' do
      let(:value) { [{ has_suffix: 'ever', has_prefix: 'what' }] }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :what
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :when
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :what_ever
        expect(subject).not_to case_eq :whichever
      end
    end

    context 'with match' do
      let(:value) { { match: 'column\d+' } }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :column_one
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :column
        expect(subject).to case_eq :column1
        expect(subject).to case_eq :column11
      end
    end

    context 'with matches' do
      let(:value) { { matches: 'column\d+' } }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :column_one
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :column
        expect(subject).to case_eq :column1
        expect(subject).to case_eq :column11
      end
    end

    context 'with a combination' do
      let(:value) { ['which', nil, { has_prefix: 'what' }, { matches: 'column\d+' }] }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :column_one
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :column
        expect(subject).to case_eq :column1
        expect(subject).to case_eq :column11
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :what
        expect(subject).not_to case_eq :whichever
        expect(subject).to case_eq :which
      end
    end

    context 'with another combination' do
      let(:value) { ['which', 'what', { has_prefix: 'what' }, { matches: 'column\d+' }] }

      it 'always matches exact value' do
        expect(subject).not_to case_eq :column_one
        expect(subject).to case_eq :new_value
        expect(subject).not_to case_eq :column
        expect(subject).to case_eq :column1
        expect(subject).to case_eq :column11
        expect(subject).to case_eq :whatever
        expect(subject).to case_eq :what
        expect(subject).not_to case_eq :whichever
        expect(subject).to case_eq :which
      end
    end
  end
end
