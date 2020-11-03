# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Transform
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
          ::Leftovers::ValueProcessors::Pluralize.new(then_processor)
        when 'singularize'
          ::Leftovers::ValueProcessors::Singularize.new(then_processor)
        when 'camelize', 'camelcase'
          ::Leftovers::ValueProcessors::Camelize.new(then_processor)
        when 'titleize', 'titlecase'
          ::Leftovers::ValueProcessors::Titleize.new(then_processor)
        when 'demodulize'
          ::Leftovers::ValueProcessors::Demodulize.new(then_processor)
        when 'deconstantize'
          ::Leftovers::ValueProcessors::Deconstantize.new(then_processor)
        when 'parameterize'
          ::Leftovers::ValueProcessors::Parameterize.new(then_processor)
        when 'underscore'
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
