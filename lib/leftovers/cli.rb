# frozen_string_literal: true

require 'optparse'
require_relative '../leftovers'
require_relative 'version'

module Leftovers
  class CLI
    attr_reader :argv, :stdout, :stderr

    def initialize(argv: [], stdout: $stdout, stderr: $stderr)
      @argv = argv
      @stdout = stdout
      @stderr = stderr

      parse_options

      exit Leftovers.run(stdout: stdout, stderr: stderr)
    end

    def parse_options # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      opts = OptionParser.new
      Leftovers.parallel = true
      Leftovers.progress = true

      opts.banner = 'Usage: leftovers [options]'
      opts.on('-q', '--quiet', 'Silences output') { Leftovers.quiet = true }
      opts.on('--[no-]parallel', 'Run in parallel or not, default --parallel') do |p|
        Leftovers.parallel = p
      end
      opts.on('--[no-]progress', 'Show progress counts or not, default --progress') do |p|
        Leftovers.progress = p
      end
      opts.on('-v', '--version', 'Returns the current version') do
        stdout.puts(Leftovers::Version)
        exit
      end
      opts.on('--dry-run', 'Output files that will be looked at') do
        stdout.puts(Leftovers::FileList.new.to_a.map(&:relative_path).join("\n"))
        exit
      end
      opts.on('-h', '--help', 'Shows this message') do
        stdout.puts(opts.help)
        exit
      end

      opts.parse(argv)
    end
  end
end
