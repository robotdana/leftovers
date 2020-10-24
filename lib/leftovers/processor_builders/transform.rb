# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Transform
      def self.require_activesupport(method)
        message = <<~MESSAGE
          Tried creating a transformer using an activesupport method (#{method}), but the activesupport gem was not available
          `gem install activesupport`
        MESSAGE

        return if Leftovers.try_require('active_support/core_ext/string', message: message)

        Leftovers.exit 1
      end

      def self.try_require_inflections
        Leftovers.try_require('active_support/inflections')
        Leftovers.try_require((Leftovers.pwd + 'config/initializers/inflections.rb').to_s)
      end

      def self.build(transform, argument, then_processor) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
        case transform.to_s
        when 'original', nil
          then_processor
        when 'downcase'
          ::Leftovers::ValueProcessors::Downcase.new(then_processor)
        when 'upcase'
          ::Leftovers::ValueProcessors::Upcase.new(then_processor)
        when 'capitalize'
          ::Leftovers::ValueProcessors::Capitalize.new(then_processor)
        when 'swapcase'
          ::Leftovers::ValueProcessors::Swapcase.new(then_processor)
        when 'pluralize'
          require_activesupport(transform)
          try_require_inflections
          ::Leftovers::ValueProcessors::Pluralize.new(then_processor)
        when 'singularize'
          require_activesupport(transform)
          try_require_inflections
          ::Leftovers::ValueProcessors::Singularize.new(then_processor)
        when 'camelize', 'camelcase'
          require_activesupport(transform)
          try_require_inflections
          ::Leftovers::ValueProcessors::Camelize.new(then_processor)
        when 'titleize', 'titlecase'
          require_activesupport(transform)
          try_require_inflections
          ::Leftovers::ValueProcessors::Titleize.new(then_processor)
        when 'demodulize'
          require_activesupport(transform)
          ::Leftovers::ValueProcessors::Demodulize.new(then_processor)
        when 'deconstantize'
          require_activesupport(transform)
          ::Leftovers::ValueProcessors::Deconstantize.new(then_processor)
        when 'parameterize'
          require_activesupport(transform)
          ::Leftovers::ValueProcessors::Parameterize.new(then_processor)
        when 'underscore'
          require_activesupport(transform)
          ::Leftovers::ValueProcessors::Underscore.new(then_processor)
        when 'split'
          ::Leftovers::ValueProcessors::Split.new(argument, then_processor)
        when 'delete_before'
          ::Leftovers::ValueProcessors::DeleteBefore.new(argument, then_processor)
        when 'delete_after'
          ::Leftovers::ValueProcessors::DeleteAfter.new(argument, then_processor)
        when 'add_prefix'
          ::Leftovers::ProcessorBuilders::AddPrefix.build(argument, then_processor)
        when 'add_suffix'
          ::Leftovers::ProcessorBuilders::AddSuffix.build(argument, then_processor)
        when 'delete_prefix'
          ::Leftovers::ValueProcessors::DeletePrefix.new(argument, then_processor)
        when 'delete_suffix'
          ::Leftovers::ValueProcessors::DeleteSuffix.new(argument, then_processor)
        # :nocov:
        else raise
          # :nocov:
        end
      end
    end
  end
end
