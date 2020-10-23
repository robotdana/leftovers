# frozen_string_literal: true

RSpec.describe Leftovers::MergedConfig do
  describe '<<' do
    it 'handles clearing memoization' do
      pending

      original_exclude_paths = subject.exclude_paths
      original_include_paths = subject.include_paths
      original_test_paths = subject.test_paths
      original_rules = subject.rules

      rails = Leftovers::Config.new(:rails)
      subject << rails

      expect(original_exclude_paths + rails.exclude_paths).to eq subject.exclude_paths
      expect(original_include_paths + rails.include_paths).to eq subject.include_paths
      expect(original_test_paths).not_to eq subject.test_paths
      expect(original_rules + rails.rules).to eq subject.rules
    end
  end

  describe 'new' do
    it 'can work without bundler' do
      allow(Leftovers).to receive(:try_require).with('bundler').and_return(false)
      expect_any_instance_of(described_class).to receive(:<<).twice # rubocop:disable RSpec/AnyInstance
      # not sure how i can expect a particular instance because it's called in the initializer

      subject
    end

    it 'only tries loading rspec once' do
      pending 'redo this when rails is split up and builtin yaml files start requiring gems'
      with_temp_dir
      temp_file '.leftovers.yml', <<~YML
        gems:
        - rspec
        - rspec
      YML

      loaded_configs = subject.instance_variable_get(:@configs).map(&:name)
      expect((loaded_configs - [:rspec]).length).to be loaded_configs.length - 1
    end
  end
end
