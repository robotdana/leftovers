# frozen_string_literal: true

require 'fast_ignore'
require 'set'
require 'parallel'

module Leftovers
  class Collector
    attr_reader :calls, :test_calls, :definitions

    def initialize
      @calls = []
      @test_calls = []
      @definitions = []
      @count = 0
      @count_calls = 0
      @count_definitions = 0
    end

    def collect
      Leftovers.reporter.prepare
      collect_file_list(Leftovers::FileList.new)
      print_progress
      Leftovers.newline
      @calls = @calls.to_set.freeze
      @test_calls = @test_calls.to_set.freeze
    end

    def collect_file_list(list)
      if Leftovers.parallel?
        Parallel.each(list, finish: method(:finish_file)) do |file|
          collect_file(file)
        end
      else
        list.each { |file| finish_file(nil, nil, collect_file(file)) }
      end
    end

    def collect_file(file)
      file_collector = ::Leftovers::FileCollector.new(file.ruby, file)
      file_collector.collect

      file_collector.to_h
    end

    def print_progress
      Leftovers.print(
        "\e[2Kchecked #{@count} files, collected #{@count_calls} calls, #{@count_definitions} definitions\r" # rubocop:disable Layout/LineLength
      )
    end

    def finish_file(_item, _index, result)
      @count += 1
      @count_calls += result[:calls].length
      @count_definitions += result[:definitions].length
      print_progress if Leftovers.progress?
      if result[:test?]
        @test_calls.concat(result[:calls])
      else
        @calls.concat(result[:calls])
      end

      @definitions.concat(result[:definitions])
    end
  end
end
