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

    def ruby # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      precompiled = []
      precompile = false

      if haml?
        precompiled << ::Leftovers::Haml.precompile(read, self)
        precompile = true
      end

      if json?
        precompiled << ::Leftovers::JSON.precompile(read, self)
        precompile = true
      end

      if erb?
        precompiled << ::Leftovers::ERB.precompile(read, self)
        precompile = true
      end

      if slim?
        precompiled << ::Leftovers::Slim.precompile(read, self)
        precompile = true
      end

      if yaml?
        precompiled << ::Leftovers::YAML.precompile(read, self)
        precompile = true
      end

      if precompile
        precompiled.join("\n")
      else
        read
      end
    end

    private

    def erb?
      Leftovers.config.erb_paths.allowed?(relative_path)
    end

    def haml?
      Leftovers.config.haml_paths.allowed?(relative_path)
    end

    def yaml?
      Leftovers.config.yaml_paths.allowed?(relative_path)
    end

    def json?
      Leftovers.config.json_paths.allowed?(relative_path)
    end

    def slim?
      Leftovers.config.slim_paths.allowed?(relative_path)
    end
  end
end
