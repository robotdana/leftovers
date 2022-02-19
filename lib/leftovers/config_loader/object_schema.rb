# frozen_string_literal: true

module Leftovers
  class ConfigLoader
    class ObjectSchema < Schema # rubocop:disable Metrics/ClassLength
      class << self
        def inherit_attributes_from(schema, require_group: true)
          @attributes ||= []
          @attributes << schema
          return if require_group

          @skip_require_group ||= []
          @skip_require_group << schema
        end

        def attributes
          @attributes ||= []
          @attributes.map(&:attributes).reduce(:merge)
        end

        def aliases
          @attributes ||= []
          @attributes.map(&:aliases).reduce(:merge)
        end

        def require_groups
          @attributes ||= []
          @skip_require_group ||= []
          (@attributes - @skip_require_group)
            .map(&:require_groups).each_with_object({}) do |require_groups, hash|
              require_groups.each do |group, keys|
                hash[group] ||= []
                hash[group] += keys
              end
            end
        end

        attr_accessor :or_schema

        def attribute(name, value_schema, aliases: nil, require_group: nil)
          @attributes ||= []
          @attributes << Attribute.new(
            name,
            value_schema,
            aliases: aliases,
            require_group: require_group
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

          if node.string? && valid_keys.include?(node.to_sym)
            node.error = "#{node.name_}#{node.to_sym} must be a hash key"
          else
            node.error += " or a hash with any of #{attributes.keys.join(', ')}"
          end
        end

        def validate_is_hash(node)
          error(node, 'be a hash')
          node.valid?
        end

        def validate_attribute_keys(node)
          node.each_key { |key| validate_recognized_key(key, node) }
          node.keys.all?(&:valid?)
        end

        def valid_keys
          attributes.keys + aliases.keys
        end

        def validate_alias_uniqueness_of_keys(node)
          node.keys.select(&:valid?)
            .group_by { |key| aliases[key.to_sym] || key.to_sym }
            .each_value do |keys|
              next unless keys.length > 1

              error_message_for_non_unique_keys(node, keys)
            end
        end

        def error_message_for_non_unique_keys(node, keys)
          keys.each do |key|
            key.error = "#{node.name_}must only use one of #{keys.uniq.join(' or ')}"
          end
        end

        def validate_recognized_key(key, node)
          return true if valid_keys.include?(key.to_sym)

          suggestions = suggestions_for_unrecognized_key(key, node)
          did_you_mean = "\nDid you mean: #{suggestions.join(', ')}" unless suggestions.empty?
          for_name = " for #{node.name}" if node.name

          key.error = "unrecognized key #{key}#{for_name}#{did_you_mean}"

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

            "include at least one of #{(group - aliases.keys).join(', ')}"
          end.compact

          error(node, missing_groups.join(' and ')) unless missing_groups.empty?

          node.valid?
        end

        def schema_for_attribute(key)
          key_sym = key.to_sym
          attributes[key_sym] || attributes.fetch(aliases[key_sym])
        end

        def validate_valid_attribute_values(node)
          node.pairs.each do |(key, value)|
            next unless key.valid?

            schema_for_attribute(key).validate(value)
          end
        end
      end
    end
  end
end
