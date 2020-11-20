# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'spellr/rake_task'
require_relative 'lib/leftovers/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)
Spellr::RakeTask.generate_task
Leftovers::RakeTask.generate_task

desc 'Test autoload'
task :test_autoload, [:times] do |_, args|
  exitstatus = 0
  puts 'Shuffled loading attempt: 1'
  exitstatus = 1 unless system('bin/test_autoload.rb --verbose')
  (args[:times]&.to_i&.-(1) || 2).times do |i|
    puts "Shuffled loading attempt: #{i + 2}"

    exitstatus = 1 unless system('bin/test_autoload.rb --verbose --only-errors')
  end
  exit exitstatus unless exitstatus == 0
end

task default: %i{test_autoload spec spellr rubocop leftovers build}
