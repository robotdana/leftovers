#!/usr/bin/env ruby
# frozen_string_literal: true

SimpleCov.print_error_status = false
SimpleCov.enable_coverage(:branch) if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5')
SimpleCov.root __dir__
SimpleCov.formatter SimpleCov::Formatter::SimpleFormatter
SimpleCov.minimum_coverage 0
SimpleCov.add_filter '/spec/'
SimpleCov.track_files '/lib/**/*.rb'

require 'parallel'

# internals of Parallel i'm sure it's fine
# this is the only way that i can tell to coverage inside parallel blocks
# without modifying my code in ugly ways

module Parallel
  def self.worker(job_factory, options, &block) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    child_read, parent_write = IO.pipe
    parent_read, child_write = IO.pipe

    pid = Process.fork do
      # here begins my additions
      SimpleCov.command_name "Parallel #{Process.pid}"
      SimpleCov.formatter SimpleCov::Formatter::SimpleFormatter
      SimpleCov.minimum_coverage 0
      SimpleCov.print_error_status = false
      SimpleCov.start
      # here ends my additions

      self.worker_number = options[:worker_number]

      begin
        options.delete(:started_workers).each(&:close_pipes)

        parent_write.close
        parent_read.close

        process_incoming_jobs(child_read, child_write, job_factory, options, &block)
      ensure
        child_read.close
        child_write.close
      end
    end

    child_read.close
    child_write.close

    Worker.new(parent_read, parent_write, pid)
  end
end
