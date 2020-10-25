#!/usr/bin/env ruby

# frozen-string-literal: true

$autoload_registry = {} # rubocop:disable Style/GlobalVars
$exit_code = 0 # rubocop:disable Style/GlobalVars

module RegisteredAutoload
  def autoload(name, path)
    autoload_registry << name if path.start_with?(Dir.pwd)
    super
  end

  def autoload_registry
    $autoload_registry[name] ||= [] # rubocop:disable Style/GlobalVars
  end
end

Module.prepend RegisteredAutoload

def try_require(parent) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  parent.autoload_registry.shuffle.each do |const_name|
    begin
      print "\e[2K\r\e[33m#{parent}::#{const_name}\e[0m\r"
      const = parent.const_get(const_name, false)
    rescue ::LoadError, ::NameError => e
      puts "\e[2K\e[31m#{parent}::#{const_name}\e[0m"
      if ARGV.include?('--verbose')
        puts "#{e.class.name}: #{e.message}"
        puts(*e.backtrace)
      end

      $exit_code = 1 # rubocop:disable Style/GlobalVars
      next
    end
    puts "\e[2K\e[32m#{parent}::#{const_name}\e[0m" unless ARGV.include?('--only-errors')

    try_require(const) if const.respond_to?(:autoload_registry)
  end
end

require_relative '../lib/leftovers'

try_require(Leftovers)

exit $exit_code # rubocop:disable Style/GlobalVars
