# frozen_string_literal: true

require 'shellwords'

module CLIHelper
  def run(argv = '')
    ::Leftovers::CLI.new(argv: ::Shellwords.split(argv)).run
  end
end

::RSpec.configure do |c|
  c.include CLIHelper, type: :cli
end
