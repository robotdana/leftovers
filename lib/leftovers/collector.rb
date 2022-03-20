# frozen_string_literal: true

require 'parallel'

module Leftovers
  class Collector
    attr_writer :progress, :parallel
    attr_reader :collection

    def initialize(collection = Collection.new)
      @count = 0
      @count_calls = 0
      @count_definitions = 0
      @progress = true
      @parallel = true
      @collection ||= collection
    end

    def collect
      collect_file_list(FileList.new)
      print_progress
      ::Leftovers.newline
    end

    def collect_file_list(list)
      if @parallel
        ::Parallel.each(list, finish: method(:finish_file)) do |file|
          collect_file(file)
        end
      else
        list.each { |file| finish_file(nil, nil, collect_file(file)) }
      end
    end

    def collect_file(file)
      file_collector = FileCollector.new(file.ruby, file)
      file_collector.collect

      file_collector.to_h
    end

    def print_progress
      ::Leftovers.print(
        "\e[2Kchecked #{@count} files, " \
          "collected #{@count_calls} calls, #{@count_definitions} definitions\r"
      )
    end

    def finish_file(_item, _index, result)
      @count += 1
      @count_calls += result[:calls].length
      @count_definitions += result[:definitions].length
      print_progress if @progress
      if result[:test?]
        @collection.test_calls.concat(result[:calls])
      else
        @collection.calls.concat(result[:calls])
      end

      @collection.definitions.concat(result[:definitions])
    end
  end
end
