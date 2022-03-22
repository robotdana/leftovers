# frozen-string-literal: true

module Leftovers
  class Runner
    attr_writer :reporter

    def run
      reporter.prepare
      collector.collect

      return reporter.report_success if collection.empty?

      reporter.report(collection)
    end

    def parallel=(value)
      collector.parallel = value
    end

    def progress=(value)
      collector.progress = value
    end

    def collection
      collector.collection
    end

    private

    def reporter
      @reporter ||= Reporter
    end

    def collector
      @collector ||= Collector.new
    end
  end
end
