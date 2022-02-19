#!/usr/bin/env ruby
# frozen_string_literal: true

require 'simplecov-console'

SimpleCov.enable_coverage(:branch)
SimpleCov.root __dir__
SimpleCov.add_filter '/spec/'
SimpleCov.track_files '/lib/**/*.rb'
SimpleCov.enable_for_subprocesses true
SimpleCov.print_error_status = true
SimpleCov.minimum_coverage line: 100, branch: 100
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
])

SimpleCov.start
