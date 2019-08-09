module Forgotten
  class Definition
    attr_reader :name
    attr_reader :location
    attr_reader :filename

    def initialize(name, location, filename)
      @name = name
      @location = location
      @filename = filename
    end


  end
end
