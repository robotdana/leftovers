# frozen_string_literal: true

::RSpec.describe ::Leftovers::MergedConfig do
  describe '<<' do
    it 'handles clearing memoization' do
      subject << :ruby
      original_exclude_paths = subject.exclude_paths
      original_include_paths = subject.include_paths
      original_test_paths = subject.test_paths
      original_precompilers = subject.precompilers
      original_dynamic = subject.dynamic
      original_keep = subject.keep
      original_test_only = subject.test_only

      expect(
        subject.instance_variables
      ).to contain_exactly(
        *::Leftovers::MergedConfig::MEMOIZED_IVARS, :@configs, :@loaded_configs
      )

      slim = ::Leftovers::Config.new(:slim)
      subject << slim

      expect(original_exclude_paths).not_to be subject.exclude_paths # it's a different empty array
      expect(original_include_paths).not_to eq subject.include_paths
      expect(original_test_paths).not_to eq subject.test_paths # it's a different set of FastIgnore
      expect(original_precompilers).not_to eq subject.precompilers

      expect(
        ::Leftovers::ProcessorBuilders::Each.build([original_dynamic, slim.dynamic])
      ).to match_nested_object subject.dynamic

      expect(
        ::Leftovers::MatcherBuilders::Or.build([original_keep, slim.keep])
      ).to match_nested_object subject.keep

      expect(
        ::Leftovers::MatcherBuilders::Or.build([original_test_only, slim.test_only])
      ).to match_nested_object subject.test_only
    end

    it 'can report when requiring' do
      config = ::Leftovers::Config.new('.invalid', content: <<~YML)
        require: 'ruby' # is a reserved gem
      YML

      expect { subject << config }.to print_warning(<<~MSG)
        cannot require 'ruby' from .invalid.yml
      MSG
    end

    it "or's correctly" do
      config = ::Leftovers::Config.new('.valid.yml', content: 'keep: method')
      config2 = ::Leftovers::Config.new(
        '.valid2.yml',
        content: 'keep: [method, { has_receiver: method2 }]'
      )
      config3 = ::Leftovers::Config.new('.valid3.yml', content: 'keep: { privacy: private }')
      config4 = ::Leftovers::Config.new(
        '.valid4.yml',
        content: 'keep: [{ has_receiver: method2 }, { privacy: private }, { type: Array }]'
      )

      subject << config
      expect(subject.keep).to be_a(::Leftovers::Matchers::NodeName)
      subject << config2
      expect(subject.keep).to be_a(::Leftovers::Matchers::Or)
      subject << config3
      expect(subject.keep).to be_a(::Leftovers::Matchers::Any)
      subject << config4
      expect(subject.keep).to be_a(::Leftovers::Matchers::Any)
    end
  end

  describe 'new' do
    it 'can work without bundler' do
      allow(::Leftovers).to receive(:try_require_cache).with('bundler').and_return(false)
      expect_any_instance_of(described_class).to receive(:<<).exactly(4).times.and_call_original # rubocop:disable RSpec/AnyInstance
      # not sure how i can expect a particular instance because it's called in the initializer

      described_class.new(load_defaults: true)
    end

    it 'only tries loading rspec once' do
      config = ::Leftovers::Config.new('.valid.yml', content: 'gems: rspec')
      config2 = ::Leftovers::Config.new('.valid2.yml', content: 'gems: rspec')

      subject << config
      subject << config2

      expect(subject.instance_variable_get(:@configs).length).to eq 3 # 2 configs + rspec once
    end
  end
end
