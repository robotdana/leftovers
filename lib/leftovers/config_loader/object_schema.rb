# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ObjectSchema < Schema # rubocop:disable Metrics/ClassLength
      class << self
        attr_accessor :or_schema

        def inherit_attributes_from(schema, require_group: true, except: nil)
          attributes_and_schemas_to_inherit_from << schema
          inherit_except[schema] = Leftovers.each_or_self(except)

          return if require_group

          skip_require_group << schema
        end

        def attributes
          nonexcluded_attributes = attributes_and_schemas_to_inherit_from.map do |attr_or_schema|
            attr_or_schema.attributes.dup.tap do |attributes_copy|
              inherit_except[attr_or_schema]&.each { |e| attributes_copy.delete(e) }
            end
          end

          nonexcluded_attributes.reduce { |a, e| a.merge(e) { raise 'Duplicate attributes' } }
        end

        def aliases
          attributes_and_schemas_to_inherit_from.map(&:aliases)
            .reduce { |a, e| a.merge(e) { raise 'Duplicate aliases' } }
        end

        def require_groups
          (attributes_and_schemas_to_inherit_from - skip_require_group).map(&:require_groups)
            .each_with_object(Hash.new { |h, k| h[k] = [] }) do |require_groups, hash|
              require_groups.each do |group, keys|
                hash[group] += keys
              end
            end
        end

        def attribute(name, value_schema, aliases: nil, require_group: nil)
          attributes_and_schemas_to_inherit_from << Attribute.new(
            name, value_schema, aliases: aliases, require_group: require_group
          )
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
            node.pairs.map { |(key, value)| pair_to_ruby(key, value) }.to_h
          else
            or_schema.to_ruby(node)
          end
        end

        private

        def inherit_except
          @inherit_except ||= {}
        end

        def skip_require_group
          @skip_require_group ||= []
        end

        def attributes_and_schemas_to_inherit_from
          @attributes_and_schemas_to_inherit_from ||= []
        end

        def pair_to_ruby(key, value)
          key_sym = key.to_sym
          key_sym = aliases[key_sym] || key_sym
          key_sym = :unless_arg if key_sym == :unless
          [key_sym, schema_for_attribute(key).to_ruby(value)]
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

          if node.string? && recognized_key?(node)
            node.error = "#{node.name_}#{node.to_sym} must be a hash key"
          else
            node.error += " or a hash with any of #{attributes.keys.join(', ')}"
          end
        end

        def recognized_key?(node)
          attributes.key?(node.to_sym) || aliases.key?(node.to_sym)
        end

        def validate_is_hash(node)
          error(node, 'be a hash')
          node.valid?
        end

        def validate_attribute_keys(node)
          node.each_key { |key| validate_recognized_key(key, node) }
          node.keys.all?(&:valid?)
        end

        def validate_alias_uniqueness_of_keys(node)
          node.keys.select(&:valid?)
            .group_by { |key| aliases[key.to_sym] || key.to_sym }
            .each_value { |keys| error_message_for_non_unique_keys(node, keys) if keys.length > 1 }
        end

        def error_message_for_non_unique_keys(node, keys)
          keys.each { |k| k.error = "#{node.name_}must only use one of #{keys.uniq.join(' or ')}" }
        end

        def validate_recognized_key(key, node)
          return true if recognized_key?(key)

          suggestions = suggestions_for_unrecognized_key(key, node)
          did_you_mean = "\nDid you mean: #{suggestions.join(', ')}" unless suggestions.empty?
          key.error = "unrecognized key #{key}#{" for #{node.name}" if node.name}#{did_you_mean}"

          false
        end

        def suggester
          @suggester ||= Suggester.new(attributes.keys)
        end

        def suggestions_for_unrecognized_key(key, node)
          existing_keys = node.keys.flat_map { |k| [k.to_sym, aliases[k.to_sym]] }.compact
          suggester.suggest(key.to_ruby) - existing_keys
        end

        def validate_required_keys(node)
          missing_groups = require_groups.map do |_name, group|
            next if node.keys.any? { |key| group.include?(key.to_sym) }

            "include at least one of #{(attributes.keys & group).join(', ')}"
          end.compact

          error(node, missing_groups.join(' and ')) unless missing_groups.empty?

          node.valid?
        end

        def schema_for_attribute(key)
          key_sym = key.to_sym
          attributes[key_sym] || attributes.fetch(aliases[key_sym])
        end

        def validate_valid_attribute_values(node)
          node.pairs.each { |(k, v)| schema_for_attribute(k).validate(v) if k.valid? }
        end
      end
    end
  end
end
