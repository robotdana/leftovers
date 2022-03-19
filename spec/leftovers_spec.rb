# frozen_string_literal: true

::RSpec.describe ::Leftovers do
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

      # ::Leftovers.pwd is stubbed by with_temp_dir
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
        dynamic:
          name: attribute
          defines:
            argument: 0
            transforms:
              - original
              - add_suffix: '='
              - add_suffix: '?'
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
      ).and(have_calls(:attribute, :foo?, :__leftovers_document))
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

      expect(subject.leftovers.flat_map(&:names)).to contain_exactly(:Actions, :initialize)
      expect(subject.collector).to have_definitions(
        :Actions, :initialize, :prepare_params, :sub_params
      ).and(have_calls(:sub_params, :prepare_params))
    end

    context 'with broken rails migration' do
      it do
        temp_file(
          'db/migrate/20220502053745_create_active_storage_tables.active_storage.rb',
          <<~RUBY
            # This migration comes from active_storage (originally 20170806125915)
            class CreateActiveStorageTables < ActiveRecord::Migration[5.2]
              def change
                # Use Active Record's configured type for primary and foreign keys
                primary_key_type, foreign_key_type = primary_and_foreign_key_types

                create_table :active_storage_blobs, id: primary_key_type do |t|
                  t.string   :key,          null: false
                  t.string   :filename,     null: false
                  t.string   :content_type
                  t.text     :metadata
                  t.string   :service_name, null: false
                  t.bigint   :byte_size,    null: false
                  t.string   :checksum

                  if connection.supports_datetime_with_precision?
                    t.datetime :created_at, precision: 6, null: false
                  else
                    t.datetime :created_at, null: false
                  end

                  t.index [ :key ], unique: true
                end

                create_table :active_storage_attachments, id: primary_key_type do |t|
                  t.string     :name,     null: false
                  t.references :record,   null: false, polymorphic: true, index: false, type: foreign_key_type
                  t.references :blob,     null: false, type: foreign_key_type

                  if connection.supports_datetime_with_precision?
                    t.datetime :created_at, precision: 6, null: false
                  else
                    t.datetime :created_at, null: false
                  end

                  t.index [ :record_type, :record_id, :name, :blob_id ], name: :index_active_storage_attachments_uniqueness, unique: true
                  t.foreign_key :active_storage_blobs, column: :blob_id
                end

                create_table :active_storage_variant_records, id: primary_key_type do |t|
                  t.belongs_to :blob, null: false, index: false, type: foreign_key_type
                  t.string :variation_digest, null: false

                  t.index [ :blob_id, :variation_digest ], name: :index_active_storage_variant_records_uniqueness, unique: true
                  t.foreign_key :active_storage_blobs, column: :blob_id
                end
              end

              private
                def primary_and_foreign_key_types
                  config = Rails.configuration.generators
                  setting = config.options[config.orm][:primary_key_type]
                  primary_key_type = setting || :primary_key
                  foreign_key_type = setting || :bigint
                  [primary_key_type, foreign_key_type]
                end
            end
          RUBY
        )

        temp_file '.leftovers.yml', <<~YML
          gems: rails
        YML
        expect(subject.leftovers.flat_map(&:names)).to be_empty
        expect(subject.collector).to have_definitions(
          :primary_and_foreign_key_types
        ).and(
          have_calls(
            :__leftovers_document, :ActiveRecord, :Migration, :[], :'5.2',
            :primary_and_foreign_key_types, :create_table, :string, :text, :bigint, :connection,
            :supports_datetime_with_precision?, :datetime, :index, :references, :foreign_key,
            :belongs_to, :private, :Rails, :configuration, :generators, :options, :orm,
            :primary_key_type
          )
        )
      end
    end
  end

  describe '::Leftovers::PrecompileError' do
    describe '#warn' do
      it 'can include a line and column' do
        error = ::Leftovers::PrecompileError.new('the message', line: 1, column: 5)
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg:1:5 the message
        MESSAGE
      end

      it 'can include a line' do
        error = ::Leftovers::PrecompileError.new('the message', line: 1)
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg:1 the message
        MESSAGE
      end

      it "doesn't print the column with no line" do
        error = ::Leftovers::PrecompileError.new('the message', column: 1)
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg the message
        MESSAGE
      end

      it 'can be given no line or column' do
        error = ::Leftovers::PrecompileError.new('the message')
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KLeftovers::PrecompileError: whatever.jpg the message
        MESSAGE
      end

      it 'prints the cause class instead if there is one' do
        error = begin
          begin
            raise ::ArgumentError, 'bad times'
          rescue ::ArgumentError
            raise ::Leftovers::PrecompileError.new('the message', line: 1, column: 5)
          end
        rescue ::Leftovers::PrecompileError => e
          e
        end
        expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
          \e[2KArgumentError: whatever.jpg:1:5 the message
        MESSAGE
      end
    end
  end
end
