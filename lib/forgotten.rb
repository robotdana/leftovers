require_relative "./forgotten/version"
require_relative "./forgotten/collector"
require_relative "./forgotten/file_list"
require_relative "./forgotten/config"
require_relative "./forgotten/reporter"

module Forgotten
  class Error < StandardError; end

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

      collector.definitions.reject do |(name, loc, filename)|
        collector.called?(name) || allowed?(name.to_s)
      end
    end
  end

  def run
    reset
    return 0 if forgotten.empty?
    forgotten.each { |(name, loc, filename)| reporter.call(name, loc, filename) }

    1
  end

  def reset
    remove_instance_variable(:@config) if defined?(@config)
    remove_instance_variable(:@collector) if defined?(@collector)
    remove_instance_variable(:@reporter) if defined?(@reporter)
    remove_instance_variable(:@forgotten) if defined?(@forgotten)
  end

  def allowed?(name)
    Forgotten.config.allowed.any? { |pattern| name.match(pattern) }
  end
end
