# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Transform
      def self.build(transform, argument, then_processor) # rubocop:disable Metrics
        case transform.to_s
        when 'original', nil
          then_processor
        when 'downcase'
          ::Leftovers::Processors::Downcase.new(then_processor)
        when 'upcase'
          ::Leftovers::Processors::Upcase.new(then_processor)
        when 'capitalize'
          ::Leftovers::Processors::Capitalize.new(then_processor)
        when 'swapcase'
          ::Leftovers::Processors::Swapcase.new(then_processor)
        when 'pluralize'
          ::Leftovers::Processors::Pluralize.new(then_processor)
        when 'singularize'
          ::Leftovers::Processors::Singularize.new(then_processor)
        when 'camelize'
          ::Leftovers::Processors::Camelize.new(then_processor)
        when 'titleize'
          ::Leftovers::Processors::Titleize.new(then_processor)
        when 'demodulize'
          ::Leftovers::Processors::Demodulize.new(then_processor)
        when 'deconstantize'
          ::Leftovers::Processors::Deconstantize.new(then_processor)
        when 'parameterize'
          ::Leftovers::Processors::Parameterize.new(then_processor)
        when 'underscore'
          ::Leftovers::Processors::Underscore.new(then_processor)
        when 'split'
          ::Leftovers::Processors::Split.new(argument, then_processor)
        when 'delete_before'
          ::Leftovers::Processors::DeleteBefore.new(argument, then_processor)
        when 'delete_before_last'
          ::Leftovers::Processors::DeleteBeforeLast.new(argument, then_processor)
        when 'delete_after'
          ::Leftovers::Processors::DeleteAfter.new(argument, then_processor)
        when 'delete_after_last'
          ::Leftovers::Processors::DeleteAfterLast.new(argument, then_processor)
        when 'add_prefix'
          ::Leftovers::ProcessorBuilders::AddPrefix.build(argument, then_processor)
        when 'add_suffix'
          ::Leftovers::ProcessorBuilders::AddSuffix.build(argument, then_processor)
        when 'delete_prefix'
          ::Leftovers::Processors::DeletePrefix.new(argument, then_processor)
        when 'delete_suffix'
          ::Leftovers::Processors::DeleteSuffix.new(argument, then_processor)
        when 'transforms'
          ::Leftovers::ProcessorBuilders::TransformSet.build(argument, then_processor)
        # :nocov:
        else raise Leftovers::UnexpectedCase, "Unhandled value #{transform.to_s.inspect}"
          # :nocov:
        end
      end
    end
  end
end
