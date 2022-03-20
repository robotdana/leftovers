# frozen_string_literal: true

require 'parser'
require 'parser/current' # to get the error message early and once.

module Leftovers
  require_relative 'leftovers/autoloader'
  include Autoloader

  MEMOIZED_IVARS = %i{
    @config
    @try_require_cache
    @stdout
    @stderr
    @pwd
  }.freeze

  class << self
    attr_writer :stdout, :stderr

    def stdout
      @stdout ||= $stdout
    end

    def stderr
      @stderr ||= $stderr
    end

    def config
      @config ||= MergedConfig.new(load_defaults: true)
    end

    def reset
      MEMOIZED_IVARS.each do |ivar|
        remove_instance_variable(ivar) if instance_variable_get(ivar)
      end
    end

    def resolution_instructions_link
      "https://github.com/robotdana/leftovers/tree/v#{VERSION}/README.md#how-to-resolve"
    end

    def warn(message)
      stderr.puts("\e[2K#{message}")
    end

    def error(message)
      warn("\e[31m#{message}\e[0m")
      exit 1
    end

    def puts(message)
      stdout.puts("\e[2K#{message}")
    end

    def print(message)
      stdout.print(message)
    end

    def newline
      stdout.puts('')
    end

    def pwd
      @pwd ||= ::Pathname.new(::Dir.pwd + '/')
    end

    def exit(status = 0)
      throw :leftovers_exit, status
    end

    def try_require(requirable, message: nil)
      warn message if !try_require_cache(requirable) && message
      try_require_cache(requirable)
    end

    def wrap_array(value)
      case value
      when nil then []
      when ::Array then value
      else [value]
      end
    end

    def unwrap_array(array)
      if array.length <= 1
        array.first
      else
        array
      end
    end

    private

    def try_require_cache(requirable)
      @try_require_cache ||= {}

      @try_require_cache.fetch(requirable) do
        require requirable
        @try_require_cache[requirable] = true
      rescue ::LoadError
        @try_require_cache[requirable] = false
      end
    end
  end
end
