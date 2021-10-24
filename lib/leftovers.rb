# frozen_string_literal: true

module Leftovers # rubocop:disable Metrics/ModuleLength
  class Error < ::StandardError; end

  autoload(:AST, "#{__dir__}/leftovers/ast")
  autoload(:Backports, "#{__dir__}/leftovers/backports")
  autoload(:CLI, "#{__dir__}/leftovers/cli")
  autoload(:Collector, "#{__dir__}/leftovers/collector")
  autoload(:ConfigValidator, "#{__dir__}/leftovers/config_validator")
  autoload(:Config, "#{__dir__}/leftovers/config")
  autoload(:DefinitionNode, "#{__dir__}/leftovers/definition_node")
  autoload(:DefinitionSet, "#{__dir__}/leftovers/definition_set")
  autoload(:Definition, "#{__dir__}/leftovers/definition")
  autoload(:ERB, "#{__dir__}/leftovers/erb")
  autoload(:FileCollector, "#{__dir__}/leftovers/file_collector")
  autoload(:FileList, "#{__dir__}/leftovers/file_list")
  autoload(:File, "#{__dir__}/leftovers/file")
  autoload(:Haml, "#{__dir__}/leftovers/haml")
  autoload(:MatcherBuilders, "#{__dir__}/leftovers/matcher_builders")
  autoload(:Matchers, "#{__dir__}/leftovers/matchers")
  autoload(:MergedConfig, "#{__dir__}/leftovers/merged_config")
  autoload(:Parser, "#{__dir__}/leftovers/parser")
  autoload(:ProcessorBuilders, "#{__dir__}/leftovers/processor_builders")
  autoload(:RakeTask, "#{__dir__}/leftovers/rake_task")
  autoload(:Reporter, "#{__dir__}/leftovers/reporter")
  autoload(:TodoReporter, "#{__dir__}/leftovers/todo_reporter")
  autoload(:DynamicProcessors, "#{__dir__}/leftovers/dynamic_processors")
  autoload(:ValueProcessors, "#{__dir__}/leftovers/value_processors")
  autoload(:VERSION, "#{__dir__}/leftovers/version")

  class << self
    attr_accessor :parallel, :progress
    attr_writer :reporter
    alias_method :parallel?, :parallel
    alias_method :progress?, :progress

    def stdout
      @stdout ||= $stdout
    end

    def stderr
      @stderr ||= $stderr
    end

    def config
      @config ||= Leftovers::MergedConfig.new(load_defaults: true)
    end

    def collector
      @collector ||= Leftovers::Collector.new
    end

    def reporter
      @reporter ||= Leftovers::Reporter.new
    end

    def leftovers
      @leftovers ||= begin
        collector.collect
        collector.definitions.reject(&:in_collection?)
      end
    end

    def run(stdout: StringIO.new, stderr: StringIO.new) # rubocop:disable Metrics/MethodLength
      @stdout = stdout
      @stderr = stderr
      return reporter.report_success if leftovers.empty?

      only_test = []
      none = []
      leftovers.sort_by(&:location_s).each do |definition|
        if !definition.test? && definition.in_test_collection?
          only_test << definition
        else
          none << definition
        end
      end

      reporter.report(only_test: only_test, none: none)
    end

    def reset # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      remove_instance_variable(:@config) if defined?(@config)
      remove_instance_variable(:@collector) if defined?(@collector)
      remove_instance_variable(:@reporter) if defined?(@reporter)
      remove_instance_variable(:@leftovers) if defined?(@leftovers)
      remove_instance_variable(:@try_require_cache) if defined?(@try_require_cache)
      remove_instance_variable(:@stdout) if defined?(@stdout)
      remove_instance_variable(:@stderr) if defined?(@stderr)
      remove_instance_variable(:@parallel) if defined?(@parallel)
      remove_instance_variable(:@pwd) if defined?(@pwd)
    end

    def resolution_instructions_link
      "https://github.com/robotdana/leftovers/tree/v#{Leftovers::VERSION}/README.md#how_to_resolve"
    end

    def warn(message)
      stderr.puts("\e[2K#{message}")
    end

    def error(message)
      warn(message)
      exit 1
    end

    def puts(message)
      stdout.puts("\e[2K#{message}")
    end

    def print(message)
      stdout.print(message)
    end

    def newline
      stdout.puts('')
    end

    def pwd
      @pwd ||= Pathname.new(Dir.pwd + '/')
    end

    def exit(status = 0)
      throw :leftovers_exit, status
    end

    def try_require(requirable, message: nil)
      warn message if !try_require_cache(requirable) && message
      try_require_cache(requirable)
    end

    def each_or_self(value, &block)
      return enum_for(__method__, value) unless block

      case value
      when nil then nil
      when Array then value.each(&block)
      else yield(value)
      end
    end

    private

    def try_require_cache(requirable)
      @try_require_cache ||= {}

      @try_require_cache.fetch(requirable) do
        begin
          require requirable
          @try_require_cache[requirable] = true
        rescue LoadError
          @try_require_cache[requirable] = false
        end
      end
    end
  end
end
