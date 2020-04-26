# frozen_string_literal: true
# frozen_string_literal: true

require 'fileutils'
require 'bundler/setup'

FileUtils.rm_rf(File.join(__dir__, '..', 'coverage'))

require 'simplecov'
require 'simplecov-console'

SimpleCov.print_error_status = true
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5')
  SimpleCov.minimum_coverage line: 100, branch: 100
else
  SimpleCov.minimum_coverage 100
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
])

SimpleCov.start

require_relative '../lib/leftovers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  require_relative './support/temp_file_helper'
  require_relative './support/cli_helper'
end

RSpec::Matchers.define :have_names do |*expected|
  match do |actual|
    @actual = actual.flat_map(&:names)
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end
