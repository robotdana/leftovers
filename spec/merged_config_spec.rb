# frozen_string_literal: true

RSpec.describe Leftovers::MergedConfig do
  before { Leftovers.reset }

  after { Leftovers.reset }

  describe '<<' do
    it 'handles clearing memoization' do
      subject << :ruby
      original_exclude_paths = subject.exclude_paths
      original_include_paths = subject.include_paths
      original_test_paths = subject.test_paths
      original_haml_paths = subject.haml_paths
      original_slim_paths = subject.slim_paths
      original_erb_paths = subject.erb_paths
      original_dynamic = subject.dynamic
      original_keep = subject.keep
      original_test_only = subject.test_only

      expect(
        subject.instance_variables
      ).to contain_exactly(
        *::Leftovers::MergedConfig::MEMOIZED_IVARS, :@configs, :@loaded_configs
      )

      rails = Leftovers::Config.new(:rails)
      subject << rails

      expect(original_exclude_paths).not_to eq subject.exclude_paths
      expect(original_include_paths).not_to eq subject.include_paths
      expect(original_test_paths).not_to eq subject.test_paths # it's a different set of FastIgnore
      expect(original_haml_paths).not_to eq subject.haml_paths
      expect(original_slim_paths).not_to eq subject.slim_paths
      expect(original_erb_paths).not_to eq subject.erb_paths

      expect(
        ::Leftovers::ProcessorBuilders::EachDynamic.build([original_dynamic, rails.dynamic])
      ).to match_nested_object subject.dynamic

      expect(
        ::Leftovers::MatcherBuilders::Or.build([original_keep, rails.keep])
      ).to match_nested_object subject.keep

      expect(
        ::Leftovers::MatcherBuilders::Or.build([original_test_only, rails.test_only])
      ).to match_nested_object subject.test_only
    end

    it 'can report when requiring' do
      config = Leftovers::Config.new('.invalid', content: <<~YML)
        require: 'ruby' # is a reserved gem
      YML

      message = <<~MSG
        cannot require 'ruby' from .invalid.yml
      MSG

      expect { subject << config }.to output(a_string_including(message)).to_stderr
    end

    it "or's correctly" do
      config = Leftovers::Config.new('.valid.yml', content: 'keep: method')
      config2 = Leftovers::Config.new('.valid2.yml', content: 'keep: method2')
      config3 = Leftovers::Config.new('.valid3.yml', content: 'keep: [method3, method4]')
      config4 = Leftovers::Config.new('.valid4.yml', content: 'keep: [method5, method6, method7]')

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
      allow(Leftovers).to receive(:try_require_cache).with('bundler').and_return(false)
      expect_any_instance_of(described_class).to receive(:<<).exactly(3).times # rubocop:disable RSpec/AnyInstance
      # not sure how i can expect a particular instance because it's called in the initializer

      described_class.new(load_defaults: true)
    end

    it 'only tries loading rspec once' do
      config = Leftovers::Config.new('.valid.yml', content: 'gems: rspec')
      config2 = Leftovers::Config.new('.valid2.yml', content: 'gems: rspec')

      subject << config
      subject << config2

      expect(subject.instance_variable_get(:@configs).length).to eq 3 # 2 configs + rspec once
    end
  end
end
