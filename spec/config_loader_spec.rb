# frozen_string_literal: true

require 'did_you_mean' # force 2.5 and 2.6 to have suggestions.

RSpec.describe Leftovers::ConfigLoader do
  before { Leftovers.reset }

  let(:name) { 'foo' }
  let(:path) { "#{name}.yml" }

  describe '#load' do
    subject { described_class.load(name, path: path, content: yaml) }

    context 'with a empty hash yaml file' do
      let(:yaml) { '{}' }

      it { is_expected.to eq({}) }
    end

    context 'with a single keyword file' do
      let(:yaml) { 'keep: my_method' }

      it { is_expected.to eq(keep: 'my_method') }
    end

    context 'with a single unrecognized keyword file' do
      let(:yaml) { 'kept: my_method' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:0 unrecognized key kept
          Did you mean: keep\e[0m
        MESSAGE
      end
    end

    context 'with both aliases' do
      let(:yaml) { '{ require: path, requires: path }' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:2 must only use one of require or requires
          Config SchemaError: foo.yml:1:17 must only use one of require or requires\e[0m
        MESSAGE
      end
    end

    context 'with a non-string key' do
      let(:yaml) { '1: 0' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:0 unrecognized key 1
          Did you mean: include_paths, exclude_paths, test_paths, precompile, requires, gems, keep, test_only, dynamic\e[0m
        MESSAGE
      end
    end

    context 'with a enum value that should be a hash key' do
      let(:yaml) { 'dynamic: { name: name, calls: { argument: 0, transforms: [ add_prefix ] } }' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:59 transforms value add_prefix must be a hash key\e[0m
        MESSAGE
      end
    end

    context 'with empty list' do
      let(:yaml) { 'keep: []' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:6 keep must not be empty\e[0m
        MESSAGE
      end
    end

    context 'with all keys used and an unknown one' do
      let(:yaml) do
        'keep: { name: { match: a, has_prefix: b, has_suffix: c, unless: d, nonsense: e } }'
      end

      it "skips all suggestions because they're already there" do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:67 unrecognized key nonsense for name\e[0m
        MESSAGE
      end
    end

    context 'with true value' do
      let(:yaml) { 'dynamic: { document: yes, call: "*" }' }

      it do
        expect(subject).to eq(dynamic: { document: true, call: '*' })
      end
    end

    context 'with true string value' do
      let(:yaml) { 'dynamic: { document: "true", call: "*" }' }

      it do
        expect(subject).to eq(dynamic: { document: true, call: '*' })
      end
    end

    context 'with false value' do
      let(:yaml) { 'dynamic: { document: false, call: "*" }' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:21 document must be true\e[0m
        MESSAGE
      end
    end

    context 'with multiple unrecognized keyword file' do
      let(:yaml) { "kept: my_method\ntests_path: spec\nuncorrectable: value" }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:0 unrecognized key kept
          Did you mean: keep
          Config SchemaError: foo.yml:2:0 unrecognized key tests_path
          Did you mean: test_paths
          Config SchemaError: foo.yml:3:0 unrecognized key uncorrectable
          Did you mean: include_paths, exclude_paths, test_paths, precompile, requires, gems, keep, test_only, dynamic\e[0m
        MESSAGE
      end
    end

    context 'with an invalid scalar value type' do
      let(:yaml) { 'gems: 1' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:6 gems must be a string or an array\e[0m
        MESSAGE
      end
    end

    context 'with an invalid array value type' do
      let(:yaml) { 'gems: [1]' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:7 gems value must be a string\e[0m
        MESSAGE
      end
    end

    context 'with a string' do
      let(:yaml) { 'gems: rails' }

      it do
        expect(subject).to eq(gems: 'rails')
      end
    end

    context 'with an array of strings' do
      let(:yaml) { 'gems: [rails]' }

      it do
        expect(subject).to eq(gems: 'rails')
      end
    end

    context 'with a simple invalid yaml file' do
      let(:yaml) { '[' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SyntaxError: foo.yml:2:1 did not find expected node content while parsing a flow node\e[0m
        MESSAGE
      end
    end

    context 'with an array config file' do
      let(:yaml) { '[]' }

      it do
        expect { catch(:leftovers_exit) { subject } }.to output(<<~MESSAGE).to_stderr
          \e[2K\e[31mConfig SchemaError: foo.yml:1:0 must be a hash\e[0m
        MESSAGE
      end
    end
  end
end
