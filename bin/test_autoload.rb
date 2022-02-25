#!/usr/bin/env ruby

# frozen-string-literal: true

@count = 0

module AutoloadRegistry
  def autoload(name, path)
    AutoloadRegistry[self] << name
    super
  end

  def self.[](klass)
    @autoload_registry ||= {}
    @autoload_registry[klass] ||= []
  end
end

Module.prepend AutoloadRegistry

def print_overwritable_blue(text)
  print "\e[2K\r\e[33m#{text}\e[0m\r"
end

def print_green(text)
  puts "\e[2K\e[32m#{text}\e[0m"
end

def print_red(text)
  puts "\e[2K\e[31m#{text}\e[0m"
end

def print_error(error)
  puts "#{error.class.name}: #{error.message}"
  puts(*error.backtrace)
end

def try_get_const(parent, const_name)
  print_overwritable_blue("#{parent}::#{const_name}")
  const = parent.const_get(const_name, false)
rescue ::LoadError, ::NameError => e
  print_red("#{parent}::#{const_name}")
  print_error(e) if ARGV.include?('--verbose')

  false
else
  print_green("#{parent}::#{const_name}") unless ARGV.include?('--only-errors')
  const
end

def try_require(parent)
  AutoloadRegistry[parent].shuffle.each do |const_name|
    const = try_get_const(parent, const_name)
    exit(1) unless const

    @count += 1

    try_require(const) if const.is_a?(Module)
  end
end

require_relative '../lib/leftovers'

try_require(Leftovers)

require 'fast_ignore'

if @count < ::FastIgnore.new(include_rules: '/lib/leftovers/**/*.rb').to_a.length
  print_red('Not all files were autoloaded')
  exit 1
end
