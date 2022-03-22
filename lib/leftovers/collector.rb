# frozen_string_literal: true

require 'parallel'

require 'parser'
require 'parser/current' # to get the error message early and once before we parallel things

module Leftovers
  class Collector
    attr_writer :progress, :parallel
    attr_reader :collection

    def initialize
      @count = 0
      @count_calls = 0
      @count_definitions = 0
      @progress = true
      @parallel = true
      @collection ||= Collection.new
    end

    def collect
      collect_file_list(FileList.new)
      ::Leftovers.puts progress_message
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

    def progress_message
      "checked #{@count} files, collected #{@count_calls} calls, #{@count_definitions} definitions"
    end

    def finish_file(_item, _index, result)
      @count += 1
      @count_calls += result[:calls].length
      @count_definitions += result[:definitions].length
      ::Leftovers.print(progress_message) if @progress

      @collection.concat(**result)
    end
  end
end
