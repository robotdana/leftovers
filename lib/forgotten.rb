require_relative "./forgotten/version"
require_relative "./forgotten/definition"
require_relative "./forgotten/argument_rule"
require_relative "./forgotten/method_rule"
require_relative "./forgotten/collector"
require_relative "./forgotten/file_list"
require_relative "./forgotten/config"
require_relative "./forgotten/reporter"

module Forgotten
  module_function

  def config
    @config ||= Forgotten::Config.new
  end

  def collector
    @collector ||= Forgotten::Collector.new
  end

  def reporter
    @reporter ||= Forgotten::Reporter.new
  end

  def forgotten
    @forgotten ||= begin
      collector.collect

      collector.definitions.reject do |definition|
        collector.calls.include?(definition.name) || allowed?(definition.name.to_s)
      end
    end
  end

  def run
    reset
    return 0 if forgotten.empty?
    forgotten.each { |definition| reporter.call(definition) }

    1
  end

  def reset
    remove_instance_variable(:@config) if defined?(@config)
    remove_instance_variable(:@collector) if defined?(@collector)
    remove_instance_variable(:@reporter) if defined?(@reporter)
    remove_instance_variable(:@forgotten) if defined?(@forgotten)
    remove_instance_variable(:@try_require) if defined?(@try_require)
  end

  def allowed?(name)
    Forgotten.config.allowed.any? { |pattern| name.match(pattern) }
  end

  def try_require(requirable, message = nil)
    @try_require ||= {}
    return @try_require[requirable] if @try_require.key?(requirable)
    @try_require[requirable] = require requirable
  rescue LoadError
    $stderr.puts message if message
    @try_require[requirable] = false
  end
end
