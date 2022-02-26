# frozen_string_literal: true

require 'pathname'

module Leftovers
  class File < Pathname
    def relative_path
      @relative_path ||= begin
        relative_path_from(Leftovers.pwd)
      rescue ArgumentError
        self
      end
    end

    def test?
      return @test if defined?(@test)

      @test = Leftovers.config.test_paths.allowed?(relative_path)
    end

    def ruby
      read = self.read

      precompiled = ::Leftovers.config.precompilers.map do |precompiler|
        precompiler.precompile(read, self)
      end.compact

      return read if precompiled.empty?

      precompiled.join("\n")
    end
  end
end
