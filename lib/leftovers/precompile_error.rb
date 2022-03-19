# frozen-string-literal: true

module Leftovers
  class PrecompileError < Error
    attr_reader :line, :column

    def initialize(message, line: nil, column: nil)
      @line = line
      @column = column
      super(message)
    end

    def warn(path:)
      line_column = ":#{line}#{":#{column}" if column}" if line
      klass = cause ? cause.class : self.class

      ::Leftovers.warn "#{klass}: #{path}#{line_column} #{message}"
    end
  end
end
