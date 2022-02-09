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
      precompiler&.precompile(read, self) || read
    end

    private

    def precompiler
      if Leftovers.config.haml_paths.allowed?(relative_path)
        ::Leftovers::Haml
      elsif Leftovers.config.slim_paths.allowed?(relative_path)
        ::Leftovers::Slim
      elsif Leftovers.config.erb_paths.allowed?(relative_path)
        ::Leftovers::ERB
      end
    end
  end
end
