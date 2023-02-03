# frozen_string_literal: true

module Leftovers
  class Exit < ::StandardError
    attr_reader :status

    def initialize(status) # rubocop:disable Lint/MissingSuper
      @status = status
    end
  end

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
      @stdout ||= ::StringIO.new
    end

    def stderr
      @stderr ||= ::StringIO.new
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

    def error(message, did_you_mean = nil)
      warn("\e[31m#{message}\e[0m")
      warn("\n#{did_you_mean}") if did_you_mean
      raise Exit, 1
    end

    def puts(message)
      stdout.puts("\e[2K#{message}")
    end

    def print(message)
      stdout.print("\e[2K#{message}\r")
    end

    def pwd
      @pwd ||= ::Pathname.new(::Dir.pwd + '/')
    end

    def exit(status = 0)
      raise Exit, status
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
