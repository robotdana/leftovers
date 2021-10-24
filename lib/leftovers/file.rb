# frozen_string_literal: true

require 'pathname'

module Leftovers
  class File < Pathname
    def relative_path
      @relative_path ||= relative_path_from(Leftovers.pwd)
    end

    def test?
      return @test if defined?(@test)

      @test = Leftovers.config.test_paths.allowed?(relative_path)
    end

    def ruby
      if Leftovers.config.haml_paths.allowed?(relative_path)
        ::Leftovers::Haml.precompile(read, self)
      elsif Leftovers.config.erb_paths.allowed?(relative_path)
        ::Leftovers::ERB.precompile(read)
      else
        read
      end
    end
  end
end
