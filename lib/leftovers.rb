# frozen_string_literal: true

require 'parser'
require 'parser/current' # to get the error message early and once.

module Leftovers # rubocop:disable Metrics/ModuleLength
  class Error < ::StandardError; end
  class UnexpectedCase < Error; end

  class PrecompileError < Error
    attr_reader :line, :column

    def initialize(message, line: nil, column: nil)
      @line = line
      @column = column
      super(message)
    end

    def warn(path:)
      line_column = ":#{line}#{":#{column}" if column}" if line
      klass = cause ? cause.class : self.class

      Leftovers.warn "#{klass}: #{path}#{line_column} #{message}"
    end
  end

  autoload(:AST, "#{__dir__}/leftovers/ast")
  autoload(:CLI, "#{__dir__}/leftovers/cli")
  autoload(:Collector, "#{__dir__}/leftovers/collector")
  autoload(:ComparableInstance, "#{__dir__}/leftovers/comparable_instance")
  autoload(:ConfigLoader, "#{__dir__}/leftovers/config_loader")
  autoload(:Config, "#{__dir__}/leftovers/config")
  autoload(:Definition, "#{__dir__}/leftovers/definition")
  autoload(:DefinitionCollection, "#{__dir__}/leftovers/definition_collection")
  autoload(:DefinitionNode, "#{__dir__}/leftovers/definition_node")
  autoload(:DefinitionNodeSet, "#{__dir__}/leftovers/definition_node_set")
  autoload(:DefinitionSet, "#{__dir__}/leftovers/definition_set")
  autoload(:DefinitionToAdd, "#{__dir__}/leftovers/definition_to_add")
  autoload(:FileCollector, "#{__dir__}/leftovers/file_collector")
  autoload(:FileList, "#{__dir__}/leftovers/file_list")
  autoload(:File, "#{__dir__}/leftovers/file")
  autoload(:MatcherBuilders, "#{__dir__}/leftovers/matcher_builders")
  autoload(:Matchers, "#{__dir__}/leftovers/matchers")
  autoload(:MergedConfig, "#{__dir__}/leftovers/merged_config")
  autoload(:Parser, "#{__dir__}/leftovers/parser")
  autoload(:Precompilers, "#{__dir__}/leftovers/precompilers")
  autoload(:ProcessorBuilders, "#{__dir__}/leftovers/processor_builders")
  autoload(:RakeTask, "#{__dir__}/leftovers/rake_task")
  autoload(:Reporter, "#{__dir__}/leftovers/reporter")
  autoload(:TodoReporter, "#{__dir__}/leftovers/todo_reporter")
  autoload(:Processors, "#{__dir__}/leftovers/processors")
  autoload(:VERSION, "#{__dir__}/leftovers/version")

  MEMOIZED_IVARS = %i{
    @config
    @collector
    @reporter
    @leftovers
    @try_require_cache
    @stdout
    @stderr
    @parallel
    @pwd
    @progress
  }.freeze

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

    def reset
      MEMOIZED_IVARS.each do |ivar|
        remove_instance_variable(ivar) if instance_variable_get(ivar)
      end
    end

    def resolution_instructions_link
      "https://github.com/robotdana/leftovers/tree/v#{Leftovers::VERSION}/README.md#how-to-resolve"
    end

    def warn(message)
      stderr.puts("\e[2K#{message}")
    end

    def error(message)
      warn("\e[31m#{message}\e[0m")
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

    def unwrap_array(array)
      if array.length <= 1
        array.first
      else
        array
      end
    end

    private

    def try_require_cache(requirable)
      @try_require_cache ||= {}

      @try_require_cache.fetch(requirable) do
        require requirable
        @try_require_cache[requirable] = true
      rescue LoadError
        @try_require_cache[requirable] = false
      end
    end
  end
end
