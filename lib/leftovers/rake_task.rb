# frozen_string_literal: true

require 'rake'
require 'shellwords'
require_relative 'cli'

module Leftovers
  class RakeTask
    include ::Rake::DSL

    def self.generate_task(name = :leftovers, *default_argv) # rubocop:disable
      new(name, default_argv)

      name
    end

    def initialize(name, default_argv)
      @name = name
      @default_argv = default_argv

      describe_task
      define_task
    end

    private

    def escaped_argv(argv = @default_argv)
      return if argv.empty?

      Shellwords.shelljoin(argv)
    end

    def describe_task
      return desc('Run leftovers') if @default_argv.empty?

      desc("Run leftovers (default args: #{escaped_argv})")
    end

    def define_task
      task(@name, :'*args') do |_, task_argv|
        argv = argv_or_default(task_argv)
        write_cli_cmd(argv)
        run(argv)
      end
    end

    def write_cli_cmd(argv)
      $stdout.puts("\e[2mleftovers #{escaped_argv(argv)}\e[0m")
    end

    def run(argv)
      Leftovers::CLI.new(argv: argv)
    rescue SystemExit => e
      raise unless e.status == 0
    end

    def argv_or_default(task_argv)
      task_argv = task_argv.to_a.compact
      task_argv.empty? ? @default_argv : task_argv
    end
  end
end
