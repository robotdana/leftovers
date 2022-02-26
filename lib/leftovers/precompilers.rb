# frozen_string_literal: true

module Leftovers
  module Precompilers
    autoload(:ERB, "#{__dir__}/precompilers/erb")
    autoload(:Haml, "#{__dir__}/precompilers/haml")
    autoload(:JSON, "#{__dir__}/precompilers/json")
    autoload(:Precompiler, "#{__dir__}/precompilers/precompiler")
    autoload(:Slim, "#{__dir__}/precompilers/slim")
    autoload(:YAML, "#{__dir__}/precompilers/yaml")

    class << self
      def build(precompilers)
        precompilers.group_by { |p| build_precompiler(p[:format]) }.map do |format, precompiler|
          Precompiler.new(
            format,
            Leftovers::MatcherBuilders::Path.build(precompiler.flat_map { |p| p[:paths] })
          )
        end
      end

      private

      def build_precompiler(format)
        case format
        when 'erb' then ::Leftovers::Precompilers::ERB
        when 'haml' then ::Leftovers::Precompilers::Haml
        when 'json' then ::Leftovers::Precompilers::JSON
        when 'slim' then ::Leftovers::Precompilers::Slim
        when 'yaml' then ::Leftovers::Precompilers::YAML
        when Hash then constantize_precompiler(format[:custom])
          # :nocov:
        else raise Leftovers::UnexpectedCase, "Unhandled value #{format}"
          # :nocov:
        end
      end

      def constantize_precompiler(precompiler)
        precompiler = "::#{precompiler}" unless precompiler.start_with?('::')

        Object.const_get(precompiler, false)
      rescue ::NameError
        Leftovers.error <<~MESSAGE
          Tried using #{precompiler}, but it wasn't available.
          add its path to `requires:` in your .leftovers.yml
        MESSAGE
      end
    end
  end
end
