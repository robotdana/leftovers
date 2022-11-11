# frozen_string_literal: true

module Leftovers
  class PrecompileError < Error
    attr_reader :line, :column

    def initialize(message, line: nil, column: nil, display_class: nil)
      @line = line
      @column = column
      @display_class = display_class
      super(message)
    end

    def warn(path:)
      ::Leftovers.warn "#{display_class}: #{path}#{location} #{message}"
    end

    private

    def display_class
      @display_class || cause&.class || self.class
    end

    def location
      return unless line
      return ":#{line}" unless column

      ":#{line}:#{column}"
    end
  end
end
