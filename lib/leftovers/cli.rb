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
        Leftovers.reset
        parse_options

        Leftovers.run(stdout: stdout, stderr: stderr)
      end
    end

    private

    attr_reader :argv, :stdout, :stderr

    def parse_options # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      opts = OptionParser.new
      Leftovers.parallel = true
      Leftovers.progress = true

      opts.banner = 'Usage: leftovers [options]'

      opts.on('--[no-]parallel', 'Run in parallel or not, default --parallel') do |p|
        Leftovers.parallel = p
      end

      opts.on('--[no-]progress', 'Show progress counts or not, default --progress') do |p|
        Leftovers.progress = p
      end

      opts.on('--dry-run', 'Output files that will be looked at') do
        Leftovers::FileList.new.each { |f| stdout.puts f.relative_path }
        Leftovers.exit
      end

      opts.on('--view-compiled', 'Output the compiled content of the files') do
        Leftovers::FileList.new(argv_rules: argv)
          .each { |f| stdout.puts "\e[0;2m#{f.relative_path}\e[0m\n#{f.ruby}" }
        Leftovers.exit
      end

      opts.on('--write-todo', 'Outputs the unused items in a todo file to gradually fix') do
        Leftovers.reporter = Leftovers::TodoReporter.new
      end

      opts.on('-v', '--version', 'Returns the current version') do
        stdout.puts(Leftovers::VERSION)
        Leftovers.exit
      end

      opts.on('-h', '--help', 'Shows this message') do
        stdout.puts(opts.help)
        Leftovers.exit
      end

      opts.parse!(argv)
    rescue OptionParser::InvalidOption => e
      stderr.puts("\e[31mCLI Error: #{e.message}\e[0m")
      stderr.puts ''
      stderr.puts(opts.help)
      Leftovers.exit 1
    end
  end
end
