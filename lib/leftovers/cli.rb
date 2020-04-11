# frozen_string_literal: true

require 'optparse'
require_relative '../leftovers'
require_relative 'version'

module Leftovers
  class CLI
    attr_reader :argv, :stdout, :stderr

    def initialize(argv: [], stdout: StringIO.new, stderr: StringIO.new)
      @argv = argv
      @stdout = stdout
      @stderr = stderr

      parse_options

      exit Leftovers.run(stdout: stdout, stderr: stderr)
    end

    def parse_options # rubocop:disable Metrics/MethodLength
      opts = OptionParser.new

      opts.banner = 'Usage: leftovers [options]'
      opts.on('-q', '--quiet', 'Silences output') { Leftovers.quiet = true }
      opts.on('--[no-]parallel', 'Run in parallel or not, default --parallel') { |p| Leftovers.parallel = p } # rubocop:disable Layout/LineLength
      opts.on('-v', '--version', 'Returns the current version') { stdout.puts(Leftovers::Version) && exit } # rubocop:disable Layout/LineLength
      opts.on('-h', '--help', 'Shows this message') { stdout.puts(opts.help) && exit }

      opts.parse(argv)
    end
  end
end
