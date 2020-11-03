# frozen_string_literal: true

module Leftovers
  module Backports
    ruby_version = Gem::Version.new(RUBY_VERSION)

    unless ruby_version >= Gem::Version.new('2.5')
      require 'set'
      module SetCaseEq
        refine ::Set do
          def ===(value)
            include?(value)
          end
        end
      end

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
    end
  end
end
