# frozen_string_literal: true

require_relative 'erb'
require_relative 'haml'
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

    RUBY_SHEBANG = /\A#!.*\bruby\b/.freeze
    def ruby_shebang?
      first_line&.match?(RUBY_SHEBANG)
    rescue ArgumentError, Errno::ENOENT
      false
    end

    def first_line
      @first_line ||= each_line.first
    end

    def ruby # rubocop:disable Metrics/MethodLength
      case extname
      when '.haml'
        Leftovers::Haml.precompile(read)
      when '.rhtml', '.rjs', '.erb'
        Leftovers::ERB.precompile(read)
      else
        read
      end
    end
  end
end
