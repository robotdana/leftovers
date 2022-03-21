# frozen-string-literal: true

::RSpec.describe ::Leftovers::Runner do
  describe '.leftovers', :with_temp_dir do
    subject { described_class.new.tap(&:run).collection }

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
      expect(subject).to have_definitions(
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
      expect(subject).to have_definitions(
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
        expect(subject).to have_definitions(
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
end
