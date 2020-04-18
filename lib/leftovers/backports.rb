# frozen_string_literal: true

module Leftovers
  ruby_version = Gem::Version.new(RUBY_VERSION)
  unless ruby_version >= Gem::Version.new('2.5')
    module StringDeletePrefixSuffix
      refine ::String do
        def delete_prefix!(str)
          slice!(0..(str.length - 1)) if start_with?(str)
          self
        end

        def delete_suffix!(str)
          slice!(-str.length..-1) if end_with?(str)
          self
        end

        def delete_prefix(str)
          dup.delete_prefix!(str)
        end

        def delete_suffix(str)
          dup.delete_suffix!(str)
        end
      end
    end

    require 'yaml'
    module YAMLSymbolizeNames
      refine YAML.singleton_class do
        alias_method :safe_load_without_symbolize_names, :safe_load
        def safe_load(path, *args, symbolize_names: false, **kwargs)
          if symbolize_names
            symbolize_names!(safe_load_without_symbolize_names(path, *args, **kwargs))
          else
            safe_load_without_symbolize_names(path, *args, **kwargs)
          end
        end

        private

        def symbolize_names!(obj) # rubocop:disable Metrics/MethodLength
          case obj
          when Hash
            obj.keys.each do |key| # rubocop:disable Style/HashEachMethods # each_key never finishes.
              obj[key.to_sym] = symbolize_names!(obj.delete(key))
            end
          when Array
            obj.map! { |ea| symbolize_names!(ea) }
          end
          obj
        end
      end
    end
  end
end
