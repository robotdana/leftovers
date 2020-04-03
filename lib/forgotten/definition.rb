module Forgotten
  class Definition
    attr_reader :name
    attr_reader :location
    attr_accessor :filename
    attr_accessor :group

    def self.wrap(strings, location, filename = nil)
      strings.each.with_object([]) do |string, group|
        d = new(string, location, filename)
        group << d
        d.group = group
      end
    end

    def initialize(name, location, filename = nil)
      @name = name
      @location = location
      @filename = filename
    end

    def names
      @names ||= group ? group.map(&:name) : [name]
    end
  end
end
