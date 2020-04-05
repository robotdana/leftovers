require 'fast_ignore'
require 'set'
require 'parallel'
require_relative 'file_collector'

module Forgotten
  class Collector
    attr_reader :calls
    attr_reader :definitions

    def initialize
      @calls = []
      @definitions = []
    end

    def collect
      Parallel.each(Forgotten::FileList.new, finish: method(:finish_parallel)) do |filename|
        file_collector = Forgotten::FileCollector.new(filename)
        file_collector.collect

        { calls: file_collector.calls, definitions: file_collector.definitions }
      end

      @calls = calls.to_set
    end

    def finish_parallel(_, _, result)
      @calls.concat(result[:calls])
      @definitions.concat(result[:definitions])
    end
  end
end
