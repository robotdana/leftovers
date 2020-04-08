module Leftovers
  class Definition
    attr_reader :name
    attr_reader :location
    attr_accessor :filename
    attr_accessor :group
    alias_method :group?, :group
    attr_accessor :test
    alias_method :test?, :test

    def self.wrap(strings, location, filename: nil, test: false)
      strings.each.with_object([]) do |string, group|
        d = new(string, location, filename: filename, test: test)
        group << d
        d.group = group
      end
    end

    def initialize(name, location, filename: nil, test: false)
      @name = name
      @location = location
      @filename = filename
      @test = test
    end

    def <=>(other)
      (filename <=> other.filename).nonzero? ||
        (location.line <=> other.location.line).nonzero? ||
        (location.column <=> other.location.column)
    end

    def full_location
      "#{filename}:#{location.line}:#{location.column}"
    end

    def highlighted_source(highlight = "\e[31m", normal = "\e[0m")
      location.source_line.to_s[0...(location.column_range.begin)].lstrip +
        highlight + location.source.to_s + normal +
        location.source_line.to_s[(location.column_range.end)..-1].rstrip
    end

    def any_in_collection?(collector)
      if group?
        group.any? { |d| d.in_collection?(collector) }
      else
        in_collection?(collector)
      end
    end

    def in_collection?(collector)
      if test?
        collector.calls.include?(name) || collector.test_calls.include?(name)
      else
        collector.calls.include?(name)
      end
    end
  end
end
