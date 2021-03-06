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
      case extname
      when '.haml'
        ::Leftovers::Haml.precompile(read, self)
      when '.rhtml', '.rjs', '.erb'
        ::Leftovers::ERB.precompile(read)
      else
        read
      end
    end
  end
end
