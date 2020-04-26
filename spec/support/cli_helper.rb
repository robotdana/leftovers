# frozen_string_literal: true

require 'shellwords'
require 'tty_string'

# just so i get a nice diff.
RSpec::Matchers.define :have_output do |expected, clear_style: false|
  match do |actual|
    @actual = TTYString.new(actual.string, clear_style: clear_style).to_s
    expect(@actual).to eq(expected)
  end

  diffable
end

module CLIHelper
  def run(argv = '')
    @exitstatus = Leftovers::CLI.new(
      argv: Shellwords.split(argv),
      stdout: stdout,
      stderr: stderr
    ).run
  end

  def stdout
    @stdout ||= StringIO.new
  end

  def stderr
    @stderr ||= StringIO.new
  end

  def exitstatus
    @exitstatus
  end
end

RSpec.configure do |c|
  c.include CLIHelper, type: :cli
end
