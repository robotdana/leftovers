# frozen_string_literal: true

require 'json'

module Leftovers
  module Precompilers
    class Precompiler
      def initialize(precompiler, matcher)
        @precompiler = precompiler
        @matcher = matcher
      end

      def precompile(content, file)
        return unless @matcher === file.relative_path

        begin
          @precompiler.precompile(content)
        rescue PrecompileError => e
          e.warn(path: file.relative_path)
          ''
        rescue ::StandardError => e
          ::Leftovers.warn "#{e.class}: #{file.relative_path} #{e.message}"
          ''
        end
      end
    end
  end
end
