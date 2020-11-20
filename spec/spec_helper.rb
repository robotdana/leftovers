# frozen_string_literal: true

require 'fileutils'
FileUtils.rm_rf(File.join(__dir__, '..', 'coverage'))
require 'bundler/setup'

if ENV['COVERAGE']
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
end

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

RSpec::Matchers.define_negated_matcher :exclude, :include
RSpec::Matchers.define :have_definitions do |*expected|
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.definitions.flat_map(&:names).uniq
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end
RSpec::Matchers.define :have_non_test_definitions do |*expected|
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.definitions.reject(&:test?).flat_map(&:names).uniq
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end
RSpec::Matchers.define :have_test_only_definitions do |*expected|
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.definitions.select(&:test?).flat_map(&:names).uniq
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end

RSpec::Matchers.define :have_calls do |*expected|
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.calls
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end
RSpec::Matchers.define :have_calls_including do |*expected|
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.calls
    expect(@actual).to include(*expected)
  end

  diffable
end
RSpec::Matchers.define :have_calls_excluding do |*expected|
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.calls
    expect(@actual).to exclude(*expected)
  end

  diffable
end

RSpec::Matchers.define :have_no_definitions do
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.definitions
    expect(@actual).to be_empty
  end

  diffable
end

RSpec::Matchers.define :have_no_non_test_definitions do
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.definitions.reject(&:test?)
    expect(@actual).to be_empty
  end

  diffable
end

RSpec::Matchers.define :have_no_test_only_definitions do
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.definitions.select(&:test?)
    expect(@actual).to be_empty
  end

  diffable
end

RSpec::Matchers.define :have_no_calls do
  match do |actual|
    actual.squash! if actual.respond_to?(:squash!)
    @actual = actual.calls
    expect(@actual).to be_empty
  end

  diffable
end

RSpec::Matchers.define :match_nested_object do |expected|
  match do |actual|
    @actual = actual
    expect(@actual.class).to eq expected.class
    @actual.instance_variables.each do |ivar|
      expect(@actual.instance_variable_get(ivar)).to match_nested_object(
        expected.instance_variable_get(ivar)
      )
    end
  end

  diffable
end
