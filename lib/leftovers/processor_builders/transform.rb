# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    module Transform
      def self.build(transform, arguments, then_processor) # rubocop:disable Metrics
        case transform
        when :original, nil
          then_processor
        when :downcase
          Processors::Downcase.new(then_processor)
        when :upcase
          Processors::Upcase.new(then_processor)
        when :capitalize
          Processors::Capitalize.new(then_processor)
        when :swapcase
          Processors::Swapcase.new(then_processor)
        when :pluralize
          Processors::Pluralize.new(then_processor)
        when :singularize
          Processors::Singularize.new(then_processor)
        when :camelize
          Processors::Camelize.new(then_processor)
        when :titleize
          Processors::Titleize.new(then_processor)
        when :demodulize
          Processors::Demodulize.new(then_processor)
        when :deconstantize
          Processors::Deconstantize.new(then_processor)
        when :parameterize
          Processors::Parameterize.new(then_processor)
        when :underscore
          Processors::Underscore.new(then_processor)
        when :transforms
          TransformSet.build(arguments, then_processor)
        else
          Each.each_or_self(arguments) do |argument|
            case transform
            when :split
              Processors::Split.new(argument, then_processor)
            when :delete_before
              Processors::DeleteBefore.new(argument, then_processor)
            when :delete_before_last
              Processors::DeleteBeforeLast.new(argument, then_processor)
            when :delete_after
              Processors::DeleteAfter.new(argument, then_processor)
            when :delete_after_last
              Processors::DeleteAfterLast.new(argument, then_processor)
            when :add_prefix
              AddPrefix.build(argument, then_processor)
            when :add_suffix
              AddSuffix.build(argument, then_processor)
            when :delete_prefix
              Processors::DeletePrefix.new(argument, then_processor)
            when :delete_suffix
              Processors::DeleteSuffix.new(argument, then_processor)
            # :nocov:
            else raise UnexpectedCase, "Unhandled value #{transform.to_s.inspect}"
              # :nocov:
            end
          end
        end
      end
    end
  end
end
