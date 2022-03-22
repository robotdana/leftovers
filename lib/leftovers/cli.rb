# frozen_string_literal: true

require 'optparse'

module Leftovers
  class CLI
    def initialize(argv: [], stdout: $stdout, stderr: $stderr)
      @argv = argv
      @stdout = stdout
      @stderr = stderr
    end

    def run
      catch(:leftovers_exit) do
        ::Leftovers.reset
        parse_options

        runner.run
      end
    end

    private

    attr_reader :argv, :stdout, :stderr

    def option_parser
      @option_parser ||= ::OptionParser.new do |o|
        o.banner = 'Usage: leftovers [options]'

        o.on('--[no-]parallel', 'Run in parallel or not, default --parallel') { |p| parallel(p) }
        o.on('--[no-]progress', 'Show live counts or not, default --progress') { |p| progress(p) }
        o.on('--dry-run', 'Print a list of files that would be looked at') { dry_run }
        o.on('--view-compiled', 'Print the compiled content of the files') { view_compiled }
        o.on('--write-todo', 'Create a config file with the existing unused items') { write_todo }
        o.on('-v', '--version', 'Print the current version') { print_version }
        o.on('-h', '--help', 'Print this message') { print_help }
      end
    end

    def parse_options
      option_parser.parse!(argv)
    rescue ::OptionParser::ParseError => e
      stderr.puts("\e[31mCLI Error: #{e.message}\e[0m")
      stderr.puts ''
      stderr.puts(option_parser.help)
      exit 1
    end

    def runner
      @runner ||= Runner.new(stdout: @stdout, stderr: @stderr)
    end

    def parallel_option(parallel)
      runner.parallel = parallel
    end

    def exit(status = 0)
      ::Leftovers.exit status
    end

    def dry_run
      FileList.new.each { |file| stdout.puts file.relative_path }

      exit
    end

    def view_compiled
      FileList.new(argv_rules: argv).each do |file|
        stdout.puts "\e[0;2m#{file.relative_path}\e[0m\n#{file.ruby}"
      end

      exit
    end

    def print_version
      stdout.puts(VERSION)

      exit
    end

    def print_help
      stdout.puts(option_parser.help)

      exit
    end

    def parallel(value)
      runner.parallel = value
    end

    def progress(value)
      runner.progress = value
    end

    def write_todo
      runner.reporter = TodoReporter
    end
  end
end
