# frozen_string_literal: true

require 'fileutils'
::FileUtils.rm_rf(::File.join(__dir__, '..', 'coverage'))
require 'bundler/setup'

require 'simplecov' if ::ENV['COVERAGE'] == '1'

require_relative '../lib/leftovers'
require 'timecop'
require 'tty_string'

::RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable ::RSpec exposing methods globally on `::Module` and `main`
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
    c.max_formatted_output_length = 2000
  end
  require_relative './support/temp_file_helper'
  require_relative './support/cli_helper'
  require_relative './support/expects_output_helper'
  require_relative './support/ruby_version_helper'

  config.after do
    Timecop.return
  end
end

::RSpec::Matchers.define_negated_matcher :exclude, :include
::RSpec::Matchers.define :have_definitions do |*expected|
  match do |actual|
    @actual = actual.definitions.compact.flat_map(&:names).uniq
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end
::RSpec::Matchers.define :have_non_test_definitions do |*expected|
  match do |actual|
    @actual = actual.definitions.compact.reject(&:test?).flat_map(&:names).uniq
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end

::RSpec::Matchers.define :have_test_only_definitions do |*expected|
  match do |actual|
    @actual = actual.definitions.compact.select(&:test?).flat_map(&:names).uniq
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end

::RSpec::Matchers.define :have_calls do |*expected|
  match do |actual|
    @actual = actual.calls.uniq
    expect(@actual).to contain_exactly(*expected)
  end

  diffable
end
::RSpec::Matchers.define :have_calls_including do |*expected|
  match do |actual|
    @actual = actual.calls.uniq
    expect(@actual).to include(*expected)
  end

  diffable
end

::RSpec::Matchers.define :have_calls_excluding do |*expected|
  match do |actual|
    @actual = actual.calls.uniq
    expect(@actual).to exclude(*expected)
  end

  diffable
end

::RSpec::Matchers.define :have_no_definitions do
  match do |actual|
    @actual = actual.definitions.compact
    expect(@actual).to be_empty
  end

  diffable
end

::RSpec::Matchers.define :have_no_non_test_definitions do
  match do |actual|
    @actual = actual.definitions.compact.reject(&:test?)
    expect(@actual).to be_empty
  end

  diffable
end

::RSpec::Matchers.define :have_no_calls do
  match do |actual|
    @actual = actual.calls
    expect(@actual).to be_empty
  end

  diffable
end

::RSpec::Matchers.define :match_nested_object do |expected|
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

::RSpec::Matchers.define :print_warning do |expected|
  match(notify_expectation_failures: true) do |actual|
    expects_output!

    actual.call
    @actual = TTYString.parse(Leftovers.stderr.string, clear_style: false)

    Leftovers.stdout.string.empty? &&
      values_match?(expected, @actual)
  end

  diffable
  supports_block_expectations
end

::RSpec::Matchers.define :print_error_and_exit do |expected|
  match(notify_expectation_failures: true) do |actual|
    expects_output!

    return_value = begin
      actual.call
    rescue ::Leftovers::Exit => e
      e.status
    rescue ::Leftovers::Error
      1
    end

    @actual = TTYString.parse(Leftovers.stderr.string, clear_style: false)

    return_value == 1 &&
      Leftovers.stdout.string.empty? &&
      values_match?(expected, @actual)
  end

  diffable
  supports_block_expectations
end

::RSpec::Matchers.define :print_output do |expected|
  match(notify_expectation_failures: true) do |actual|
    expects_output!

    actual.call
    @actual = TTYString.parse(Leftovers.stdout.string, clear_style: false)

    Leftovers.stderr.string.empty? &&
      values_match?(expected, @actual)
  end

  diffable
  supports_block_expectations
end

::RSpec::Matchers.define :print_output_and_exit_with_success do |expected|
  match(notify_expectation_failures: true) do |actual|
    expects_output!

    return_value = begin
      actual.call
    rescue ::Leftovers::Exit => e
      e.status
    rescue ::Leftovers::Error
      1
    end

    @actual = TTYString.parse(Leftovers.stdout.string, clear_style: false)

    return_value == 0 &&
      Leftovers.stderr.string.empty? &&
      values_match?(expected, @actual)
  end

  diffable
  supports_block_expectations
end

::RSpec::Matchers.define :print_output_and_exit_with_failure do |expected|
  match(notify_expectation_failures: true) do |actual|
    expects_output!

    return_value = begin
      actual.call
    rescue ::Leftovers::Exit => e
      e.status
    rescue ::Leftovers::Error
      1
    end

    @actual = TTYString.parse(Leftovers.stdout.string, clear_style: false)

    return_value == 1 &&
      Leftovers.stderr.string.empty? &&
      values_match?(expected, @actual)
  end

  diffable
  supports_block_expectations
end
