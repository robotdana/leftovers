# frozen-string-literal: true

require_relative '../processor_builders/add_prefix'
require_relative '../processor_builders/add_suffix'
require_relative '../value_processors/split'
require_relative '../value_processors/delete_prefix'
require_relative '../value_processors/delete_suffix'
require_relative '../value_processors/delete_after'
require_relative '../value_processors/delete_before'
require_relative '../value_processors/downcase'
require_relative '../value_processors/upcase'
require_relative '../value_processors/capitalize'
require_relative '../value_processors/swapcase'
require_relative '../value_processors/pluralize'
require_relative '../value_processors/singularize'
require_relative '../value_processors/camelize'
require_relative '../value_processors/titleize'
require_relative '../value_processors/demodulize'
require_relative '../value_processors/deconstantize'
require_relative '../value_processors/parameterize'
require_relative '../value_processors/underscore'
require_relative '../value_processors/replace_value'

module Leftovers
  module ProcessorBuilders
    module Transform
      def self.require_activesupport(method)
        message = <<~MESSAGE
          Tried transforming a string using an activesupport method (#{method}), but the activesupport gem was not available
          `gem install activesupport`
        MESSAGE

        Leftovers.try_require('active_support/core_ext/string', message: message)
        Leftovers.try_require('active_support/inflections', message: message)
        Leftovers.try_require(
          ::File.join(Leftovers.pwd, 'config', 'initializers', 'inflections.rb')
        )

        Leftovers.exit 1 unless defined?(::ActiveSupport)
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
          ::Leftovers::ValueProcessors::Pluralize.new(then_processor)
        when 'singularize'
          require_activesupport(transform)
          ::Leftovers::ValueProcessors::Singularize.new(then_processor)
        when 'camelize', 'camelcase'
          require_activesupport(transform)
          ::Leftovers::ValueProcessors::Camelize.new(then_processor)
        when 'titleize', 'titlecase'
          require_activesupport(transform)
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
        when 'replace_with'
          ::Leftovers::ValueProcessors::ReplaceValue.new(argument, then_processors)
        else raise
        end
      end
    end
  end
end
