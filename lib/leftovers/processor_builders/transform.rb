# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module Transform
      def self.build(transform, arguments, then_processor) # rubocop:disable Metrics
        case transform
        when :original, nil then then_processor
        when :downcase then Processors::Downcase.new(then_processor)
        when :upcase then Processors::Upcase.new(then_processor)
        when :capitalize then Processors::Capitalize.new(then_processor)
        when :swapcase then Processors::Swapcase.new(then_processor)
        when :pluralize then Processors::Pluralize.new(then_processor)
        when :singularize then Processors::Singularize.new(then_processor)
        when :camelize then Processors::Camelize.new(then_processor)
        when :titleize then Processors::Titleize.new(then_processor)
        when :demodulize then Processors::Demodulize.new(then_processor)
        when :deconstantize then Processors::Deconstantize.new(then_processor)
        when :parameterize then Processors::Parameterize.new(then_processor)
        when :underscore then Processors::Underscore.new(then_processor)
        when :transforms then TransformSet.build(arguments, then_processor)
        else
          Each.each_or_self(arguments) do |arg|
            case transform
            when :split then Processors::Split.new(arg, then_processor)
            when :delete_before then Processors::DeleteBefore.new(arg, then_processor)
            when :delete_before_last then Processors::DeleteBeforeLast.new(arg, then_processor)
            when :delete_after then Processors::DeleteAfter.new(arg, then_processor)
            when :delete_after_last then Processors::DeleteAfterLast.new(arg, then_processor)
            when :add_prefix then AddPrefix.build(arg, then_processor)
            when :add_suffix then AddSuffix.build(arg, then_processor)
            when :delete_prefix then Processors::DeletePrefix.new(arg, then_processor)
            when :delete_suffix then Processors::DeleteSuffix.new(arg, then_processor)
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
