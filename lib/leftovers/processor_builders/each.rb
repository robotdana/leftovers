# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    class Each
      def self.build(processors)
        self[:each].build(processors)
      end

      def self.each_or_self(value, &block)
        self[:each].each_or_self(value, &block)
      end

      def self.[](processor_name)
        @each ||= {
          each: new(::Leftovers::Processors::Each),
          each_for_definition_set: new(::Leftovers::Processors::EachForDefinitionSet)
        }

        @each.fetch(processor_name)
      end

      def initialize(processor_class = ::Leftovers::Processors::Each)
        @processor_class = processor_class
      end

      def each_or_self(value, &block)
        case value
        when nil then nil
        when Array then build(value.map(&block))
        else build([yield(value)])
        end
      end

      def build(processors)
        processors = compact(processors)

        case processors.length
        # :nocov:
        when 0 then raise Leftovers::UnexpectedCase, "Unhandled value #{processors.inspect}"
        # :nocov:
        when 1 then processors.first
        else @processor_class.new(processors)
        end
      end

      def flatten(processors)
        case processors
        when ::Leftovers::Processors::Each, @processor_class
          flatten(processors.processors)
        when Array
          processors.flat_map { |v| flatten(v) }
        when ::Leftovers::Processors::IfMatcher
          flatten_if_matcher(processors)
        else
          [processors]
        end
      end

      def flatten_if_matcher(processor)
        then_processors = flatten(processor.then_processor)
        return processor if then_processors.length <= 1

        then_processors.map do |then_processor|
          processor.class.new(processor.matcher, then_processor)
        end
      end

      def group_same_processor(if_matchers)
        if_matchers.group_by(&:then_processor).map do |then_processor, group|
          next group.first unless group.length > 1

          ::Leftovers::Processors::IfMatcher.new(
            ::Leftovers::MatcherBuilders::Or.build(group.map(&:matcher)),
            then_processor
          )
        end
      end

      def group_same_matcher(if_matchers)
        if_matchers.group_by(&:matcher).map do |matcher, group|
          next group.first unless group.length > 1

          ::Leftovers::Processors::IfMatcher.new(
            matcher,
            build(group.map(&:then_processor))
          )
        end
      end

      def group_if_matcher(processors)
        if_matchers, other_processors = processors.partition do |processor|
          processor.is_a?(::Leftovers::Processors::IfMatcher)
        end

        if_matchers = group_same_processor(if_matchers)
        if_matchers = group_same_matcher(if_matchers)

        if_matchers + other_processors
      end

      def compact(processors)
        processors = flatten(processors).compact

        return processors if processors.length <= 1

        group_if_matcher(processors)
      end
    end
  end
end
