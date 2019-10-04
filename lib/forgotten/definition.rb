module Forgotten
  class Definition
    attr_reader :name
    attr_reader :location
    attr_accessor :filename

    def initialize(name, location, filename = nil)
      @name = name
      @location = location
      @filename = filename
    end
  end
end
