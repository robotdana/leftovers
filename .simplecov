#!/usr/bin/env ruby

SimpleCov.print_error_status = false
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5')
  SimpleCov.enable_coverage(:branch)
end
SimpleCov.root __dir__
SimpleCov.formatter SimpleCov::Formatter::SimpleFormatter
SimpleCov.minimum_coverage 0
SimpleCov.add_filter '/backports'
SimpleCov.add_filter '/spec/'
SimpleCov.add_filter '/bin/generate' # because i have to skip and mock some of it for expediency reasons
require 'parallel'

# internals of Parallel i'm sure it's fine
# this is the only way that i can tell to coverage inside parallel blocks
# without modifying my code in ugly ways

module Parallel
  def self.worker(job_factory, options, &block)
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
