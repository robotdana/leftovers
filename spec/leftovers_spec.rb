# frozen_string_literal: true

RSpec.describe Leftovers do
  before { described_class.reset }

  after { described_class.reset }

  describe 'version' do
    changelog = ::File.read(::File.expand_path('../CHANGELOG.md', __dir__))
    changelog_version = changelog.match(/^# v([\d.]+)$/)&.captures&.first

    it "has the version number: #{changelog_version}, matching the changelog" do
      expect(described_class::VERSION).to eq changelog_version
    end
  end

  describe '.each_or_self' do
    it "doesn't yield nil" do
      expect { |b| described_class.each_or_self(nil, &b) }.not_to yield_control
    end

    it 'yields a single value' do
      expect { |b| described_class.each_or_self(1, &b) }.to yield_with_args(1)
    end

    it 'yields a single layer array' do
      expect { |b| described_class.each_or_self([1, 2, 3], &b) }.to yield_successive_args(1, 2, 3)
    end

    it 'yields a hash as a single item' do
      expect { |b| described_class.each_or_self(this: :that, another: :thing, &b) }
        .to yield_with_args(this: :that, another: :thing)
    end

    context 'when an enumerator' do
      it "doesn't yield nil" do
        expect { |b| described_class.each_or_self(nil).each(&b) }.not_to yield_control
      end

      it 'yields a single value' do
        expect { |b| described_class.each_or_self(1).each(&b) }.to yield_with_args(1)
      end

      it 'yields a single layer array' do
        expect do |b|
          described_class.each_or_self([1, 2, 3]).each(&b)
        end.to yield_successive_args(1, 2, 3)
      end

      it 'yields a hash as a single item' do
        expect { |b| described_class.each_or_self(this: :that, another: :thing).each(&b) }
          .to yield_with_args(this: :that, another: :thing)
      end
    end
  end

  describe '.reset' do
    before { with_temp_dir }

    it 'unmemoizes everything' do
      described_class.run
      described_class.try_require('not here')

      original_stdout = described_class.stdout
      original_stderr = described_class.stderr
      original_config = described_class.config
      original_collector = described_class.collector
      original_reporter = described_class.reporter
      original_leftovers = described_class.leftovers
      original_parallel = described_class.parallel = true
      original_progress = described_class.progress = true

      # Leftovers.pwd is stubbed by with_temp_dir
      expect(
        subject.instance_variables
      ).to contain_exactly(
        *(::Leftovers::MEMOIZED_IVARS - [:@pwd])
      )

      described_class.reset

      expect(described_class.stdout).not_to eq original_stdout
      expect(described_class.stderr).not_to eq original_stderr
      expect(described_class.config).not_to eq original_config
      expect(described_class.collector).not_to eq original_collector
      expect(described_class.reporter).not_to eq original_reporter
      expect(described_class.leftovers).not_to be original_leftovers
      expect(described_class.parallel).not_to eq original_parallel
      expect(described_class.progress).not_to eq original_progress
    end
  end

  describe '.leftovers' do
    subject { described_class }

    before { with_temp_dir }

    it "doesn't care about using one of multiple simultaneous defined methods" do
      temp_file '.leftovers.yml', <<~YML
        gems: rails
      YML

      temp_file 'app/models/foo.rb', <<~RUBY
        attribute :foo

        def check_foo
          foo?
        end
      RUBY

      expect { subject.leftovers }.not_to output.to_stderr
      expect(subject.leftovers.flat_map(&:names)).to eq [:check_foo]
      expect(subject.collector).to have_definitions(
        :foo, :foo?, :foo=, :check_foo
      ).and(have_calls(:attribute, :foo?))
    end

    it "doesn't think method calls in the same file are leftovers" do
      temp_file 'foo.rb', <<~RUBY
        class Actions
          def initialize(params)
            prepare_params(params)
          end

          def prepare_params(params)
            {
              attributes: sub_params(params)
            }
          end

          def sub_params(params)
            true
          end
        end
      RUBY

      expect(subject.leftovers.flat_map(&:names)).to eq [:Actions]
      expect(subject.collector).to have_definitions(
        :Actions, :prepare_params, :sub_params
      ).and(have_calls(:sub_params, :prepare_params))
    end
  end

  describe 'Leftovers::PrecompileError' do
    describe '#warn' do
      it 'can include a line and column' do
        error = Leftovers::PrecompileError.new('the message', line: 1, column: 5)
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg:1:5 the message
        MESSAGE
      end

      it 'can include a line' do
        error = Leftovers::PrecompileError.new('the message', line: 1)
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg:1 the message
        MESSAGE
      end

      it "doesn't print the column with no line" do
        error = Leftovers::PrecompileError.new('the message', column: 1)
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg the message
        MESSAGE
      end

      it 'can be given no line or column' do
        error = Leftovers::PrecompileError.new('the message')
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg the message
        MESSAGE
      end

      it 'prints the cause class instead if there is one' do
        error = begin
          begin
            raise ArgumentError, 'bad times'
          rescue ArgumentError
            raise Leftovers::PrecompileError.new('the message', line: 1, column: 5)
          end
        rescue Leftovers::PrecompileError => e
          e
        end
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KArgumentError: whatever.jpg:1:5 the message
        MESSAGE
      end
    end
  end
end
