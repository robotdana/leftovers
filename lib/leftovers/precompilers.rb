# frozen_string_literal: true

module Leftovers
  module Precompilers
    include Autoloader

    class << self
      def build(precompilers)
        precompilers.group_by { |p| build_precompiler(p[:format]) }.map do |format, precompiler|
          Precompiler.new(
            format,
            MatcherBuilders::Path.build(precompiler.flat_map { |p| p[:paths] })
          )
        end
      end

      private

      def build_precompiler(format)
        case format
        when :erb then ERB
        when :haml then Haml
        when :json then JSON
        when :slim then Slim
        when :yaml then YAML
        when ::Hash then constantize_precompiler(format[:custom])
          # :nocov:
        else raise UnexpectedCase, "Unhandled value #{format}"
          # :nocov:
        end
      end

      def constantize_precompiler(precompiler)
        precompiler = "::#{precompiler}" unless precompiler.start_with?('::')

        ::Object.const_get(precompiler, false)
      rescue ::NameError
        ::Leftovers.error <<~MESSAGE
          Tried using #{precompiler}, but it wasn't available.
          add its path to `requires:` in your .leftovers.yml
        MESSAGE
      end
    end
  end
end
