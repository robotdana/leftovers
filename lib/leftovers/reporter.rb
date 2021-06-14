# frozen_string_literal: true

module Leftovers
  class Reporter
    def report(only_test:, none:)
      report_list('Only directly called in tests:', only_test)
      report_list('Not directly called at all:', none)
    end

    private

    def report_list(title, list)
      return if list.empty?

      puts red(title)
      list.each { |d| print_definition(d) }
    end

    def print_definition(definition)
      puts "#{aqua definition.location_s} "\
        "#{definition} "\
        "#{grey definition.highlighted_source("\e[33m", "\e[0;2m")}"
    end

    def puts(string)
      Leftovers.puts(string)
    end

    def red(string)
      "\e[31m#{string}\e[0m"
    end

    def aqua(string)
      "\e[36m#{string}\e[0m"
    end

    def grey(string)
      "\e[2m#{string}\e[0m"
    end
  end
end
