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
      forgotten = collector.definitions.reject do |definition|
        allowed?(definition.name.to_s) ||
          definition.any_in_collection?(collector)
      end
    end
  end

  def run
    reset
    return 0 if forgotten.empty?

    only_test = []
    none = []
    forgotten.sort.each do |definition|
      if !definition.test? && collector.test_calls.include?(definition.name)
        only_test << definition
      else
        none << definition
      end
    end

    unless only_test.empty?
      puts "\e[31mOnly directly called in tests:\e[0m"
      only_test.each { |definition| reporter.call(definition) }
    end

    unless none.empty?
      puts "\e[31mNot directly called at all:\e[0m"
      none.each { |definition| reporter.call(definition) }
    end

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
    Forgotten.config.allowed.match?(name)
  end

  def try_require(requirable, message = nil)
    @try_require ||= {}
    return @try_require[requirable] if @try_require.key?(requirable)
    @try_require[requirable] = require requirable
  rescue LoadError
    $stderr.puts message if message
    @try_require[requirable] = false
  end

  def wrap_array(value)
    case value
    when Hash
      [value]
    when Array
      value
    else
      Array(value)
    end
  end
end
