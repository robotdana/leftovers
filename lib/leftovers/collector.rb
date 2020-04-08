require 'fast_ignore'
require 'set'
require 'parallel'
require_relative 'file_collector'

module Leftovers
  class Collector
    attr_reader :calls
    attr_reader :test_calls
    attr_reader :definitions

    def initialize
      @calls = []
      @test_calls = []
      @definitions = []
      @count = 0
      @count_calls = 0
      @count_definitions = 0
    end

    def collect
      # Parallel.each(Leftovers::FileList.new, finish: method(:finish_parallel)) do |filename|
      Leftovers::FileList.new.each do |filename|
        file_collector = Leftovers::FileCollector.new(filename)
        file_collector.collect

        file_collector.to_h
        finish_parallel(nil, nil, file_collector.to_h)
      end
      puts ''
      @calls = calls.to_set
      @test_calls = test_calls.to_set
    end

    def finish_parallel(_, _, result)
      print "checked #{@count += 1} files, collected #{@count_calls += result[:calls].length} calls, #{@count_definitions += result[:definitions].length} definitions\r"
      if result[:test?]
        @test_calls.concat(result[:calls])
      else
        @calls.concat(result[:calls])
      end

      @definitions.concat(result[:definitions])
    end
  end
end
