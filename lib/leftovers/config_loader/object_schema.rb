# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ObjectSchema < Schema
      class << self
        attr_accessor :or_schema

        def inherit_attributes_from(schema, require_group: true, except: nil)
          attributes_and_schemas_to_inherit_from << InheritSchemaAttributes.new(
            schema, require_group: require_group, except: except
          )
        end

        def attributes
          attributes_and_schemas_to_inherit_from.flat_map(&:attributes)
        end

        def attribute(name, value_schema, aliases: nil, require_group: nil, suggest: true)
          attributes_and_schemas_to_inherit_from << Attribute.new(
            name, value_schema,
            aliases: aliases, require_group: require_group, suggest: suggest
          )
        end

        def require_groups
          attributes.group_by(&:require_group).tap { |rg| rg.delete(nil) }.values
        end

        def validate(node)
          if node.hash?
            validate_attributes(node)
          elsif or_schema
            validate_or_schema(node)
          else
            validate_is_hash(node)
          end
        end

        def to_ruby(node)
          if node.hash?
            node.pairs.map { |(key, value)| attribute_for_key(key).to_ruby(value) }.to_h
          else
            or_schema.to_ruby(node)
          end
        end

        private

        def attributes_and_schemas_to_inherit_from
          @attributes_and_schemas_to_inherit_from ||= []
        end

        def validate_attributes(node)
          validate_attribute_keys(node) && validate_required_keys(node)
          validate_alias_uniqueness_of_keys(node)
          validate_valid_attribute_values(node)

          node.children.all?(&:valid?)
        end

        def validate_or_schema(node)
          or_schema.validate(node)
          return true if node.valid?

          if node.string? && attribute_for_key(node)
            node.error = "#{node.name_}#{node.to_sym} must be a hash key"
          else
            suggestions = attributes.select(&:suggest?).map(&:name).join(', ')
            node.error += " or a hash with any of #{suggestions}"
          end
        end

        def attribute_for_key(node)
          attributes.find { |attr| attr.name?(node) }
        end

        def validate_is_hash(node)
          error(node, 'be a hash')
        end

        def validate_attribute_keys(node)
          node.each_key { |key| validate_recognized_key(key, node) }
          node.keys.all?(&:valid?)
        end

        def validate_alias_uniqueness_of_keys(node)
          node.keys.select(&:valid?)
            .group_by { |key| attribute_for_key(key) }
            .each_value { |keys| error_message_for_non_unique_keys(node, keys) if keys.length > 1 }

          node.valid?
        end

        def error_message_for_non_unique_keys(node, keys)
          keys.each { |k| k.error = "#{node.name_}must only use one of #{keys.uniq.join(' or ')}" }
        end

        def validate_recognized_key(key, node)
          return true if attribute_for_key(key)

          suggestions = suggestions_for_unrecognized_key(key, node)
          did_you_mean = "\nDid you mean: #{suggestions.join(', ')}" unless suggestions.empty?
          key.error = "unrecognized key #{key}#{" for #{node.name}" if node.name}#{did_you_mean}"

          false
        end

        def suggester
          @suggester ||= Suggester.new(attributes.select(&:suggest?).map(&:name))
        end

        def suggestions_for_unrecognized_key(key, node)
          suggester.suggest(key.to_ruby) - node.keys.map { |k| attribute_for_key(k)&.name }.compact
        end

        def validate_required_keys(node) # rubocop:disable Metrics/CyclomaticComplexity
          missing_groups = require_groups.map do |group|
            next if node.keys.any? { |key| group.any? { |attr| attr.name?(key) } }

            "include at least one of #{group.select(&:suggest?).map(&:name).join(', ')}"
          end.compact

          return true if missing_groups.empty?

          error(node, missing_groups.join(' and '))
        end

        def validate_valid_attribute_values(node)
          node.pairs.each { |(k, v)| attribute_for_key(k).validate_value(v) if k.valid? }
        end
      end
    end
  end
end
