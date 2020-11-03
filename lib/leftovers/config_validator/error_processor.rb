# frozen-string-literal: true

::Leftovers.try_require 'did_you_mean'

module Leftovers
  module ConfigValidator
    module ErrorProcessor # rubocop:disable Metrics/ModuleLength
      LENGTH_TYPE = %w{minItems minLength minProperties}.freeze
      TYPE_TYPE = %w{null string boolean integer number array object}.freeze
      VALUE_TYPE = %w{enum const}.freeze
      REQUIRED_TYPE = %w{required}.freeze

      class << self
        def process(errors) # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
          error_data_pointers = []
          errors = group_errors(errors)
          errors.flat_map do |data_pointer, error_group| # rubocop:disable Metrics/BlockLength
            next if error_data_pointers.find { |x| x.start_with?(data_pointer) }

            # original_error_group = error_group.dup
            length_errors = error_group.select { |x| LENGTH_TYPE.include?(x['type']) }
            value_errors = error_group.select { |x| VALUE_TYPE.include?(x['type']) }
            type_errors = error_group.select { |x| TYPE_TYPE.include?(x['type']) }
            required_errors = error_group.select { |x| REQUIRED_TYPE.include?(x['type']) }
            messages = []

            if !type_errors.empty? && (error_group - type_errors).empty?
              error_group -= type_errors
              error_data_pointers << data_pointer
              any_of = group_by_same_any_of(type_errors)
              if any_of.length == 1
                was_class = to_json_type(type_errors.first['data'])
                error_types = type_errors.map { |x| x['type'] }

                messages << <<~MESSAGE.chomp
                  #{data_pointer}: must be #{an to_sentence(error_types, 'or')} (was #{an was_class})
                MESSAGE
                # :nocov:
              else
                nil
                # :nocov:
              end
            elsif !required_errors.empty? && error_group.first['data'].is_a?(Hash)
              error_data_pointers << data_pointer
              group_by_same_any_of(required_errors).each do |_any_of_key, any_of_value|
                required_keywords = any_of_value.flat_map { |x| x['details']['missing_keys'] }
                error_group -= any_of_value
                if any_of_value.length > 1
                  messages << <<~MESSAGE
                    #{data_pointer}: requires at least one of these keywords: #{to_sentence(required_keywords, 'or')}
                  MESSAGE

                  # :nocov:
                else
                  nil
                  # :nocov:
                  # messages << "#{data_pointer}: requires keyword: #{required_keywords.first}"
                end
              end
            elsif !length_errors.empty?
              error_data_pointers << data_pointer
              messages << "#{data_pointer}: can't be empty"
            end

            error_group.each do |error| # rubocop:disable Metrics/BlockLength
              type = error['type']
              case type
              when 'schema'
                error_data_pointers << data_pointer
                parent_pointer = parent(data_pointer)
                if ::File.basename(error['schema_pointer']) == 'additionalProperties'
                  keyword = tail(data_pointer)
                  parent_schema_pointer = parent(error['schema_pointer'])
                  actual_keywords = schema_hash_dig(parent_schema_pointer)['properties'].keys
                  corrections = did_you_mean(keyword, actual_keywords)

                  messages << <<~MESSAGE.chomp
                    #{parent_pointer}: invalid property keyword: #{keyword}
                    Valid keywords: #{to_sentence actual_keywords}
                    #{"Did you mean? #{to_sentence corrections, 'or'}" unless corrections.empty?}
                  MESSAGE
                  # :nocov:
                else
                  nil
                  # :nocov:
                end
              when 'enum'
                next if error['data'].is_a?(Hash)

                error_data_pointers << data_pointer
                given_value = error['data']
                valid_values = value_errors.first['schema']['enum']
                corrections = did_you_mean(given_value, valid_values)
                messages << <<~MESSAGE
                  #{data_pointer}: can't be: #{given_value}
                  Valid values: #{to_sentence valid_values, 'or'}
                  #{"Did you mean? #{to_sentence corrections, 'or'}" unless corrections.empty?}
                MESSAGE
              when 'not'
                next unless error['data'].is_a?(Hash)

                error_data_pointers << data_pointer
                if error['schema']['required']
                  invalid_combinations = error['schema']['required'] & error['data'].keys
                  messages << <<~MESSAGE
                    #{data_pointer}: use only one of: #{to_sentence invalid_combinations, 'or'}
                  MESSAGE
                  # :nocov:
                else
                end
              else
              end
              # :nocov:
            end

            if messages.empty?
              error_data_pointers << data_pointer
              "#{data_pointer} is invalid"
            else
              messages
            end
          end.compact.map(&:strip)
        end

        private

        def did_you_mean(word, dictionary)
          # :nocov:
          if defined?(::DidYouMean::SpellChecker)
            ::DidYouMean::SpellChecker.new(dictionary: dictionary).correct(word)
          else
            []
          end
          # :nocov:
        end

        def schema_hash_dig(schema_pointer)
          ::Leftovers::ConfigValidator::SCHEMA_HASH.dig(
            *schema_pointer.split('/').drop(1).map { |x| x.match?(/\A\d+\z/) ? x.to_i : x }
          )
        end

        def parent(pointer)
          ::File.dirname(pointer)
        end

        def tail(pointer)
          ::File.basename(pointer)
        end

        def to_json_type(value)
          case value
          when Hash then 'object'
          when Float then 'number'
          when true, false then 'boolean'
          when nil then 'null'
          else value.class.name.downcase
          end
        end

        def an(str)
          case str[0]
          # when nil then ""
          when 'a', 'e', 'i', 'o', 'u' then "an #{str}"
          else "a #{str}"
          end
        end

        def to_sentence(ary, join_word = 'and')
          case ary.length
          when 1 then ary.first
          when 2 then ary.join(" #{join_word} ")
          else
            ary = ary.dup
            last = ary.pop(2)
            [*ary, last.join(", #{join_word} ")].join(', ')
          end
        end

        def group_errors(errors)
          errors = errors.map do |x|
            x.delete('root_schema')
            x
          end
          errors.group_by { |x| x['data_pointer'] }.sort.reverse.to_h
        end

        def group_by_same_any_of(errors)
          errors.group_by do |x|
            x['schema_pointer'].match?(%r{/anyOf/\d+$}) && parent(parent(x['schema_pointer']))
          end
        end
      end
    end
  end
end
