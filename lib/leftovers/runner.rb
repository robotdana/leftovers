# frozen-string-literal: true

module Leftovers
  class Runner
    attr_writer :reporter
    attr_reader :collection # leftovers:test_only

    def initialize(stdout: ::StringIO.new, stderr: ::StringIO.new)
      Leftovers.stdout = stdout
      Leftovers.stderr = stderr
      @reporter = Reporter
      @collector = Collector.new
      @collection = @collector.collection
    end

    def run
      @reporter.prepare
      @collector.collect

      return @reporter.report_success if @collection.empty?

      @reporter.report(@collection)
    end

    def parallel=(value)
      @collector.parallel = value
    end

    def progress=(value)
      @collector.progress = value
    end
  end
end
