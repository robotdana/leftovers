require 'haml_lint'

module HamlLint
  class RubyExtractor
    def add_dummy_puts(_node, _annotation = nil)
    end
  end
end

module Forgotten
  module Haml
    class Document
      def initialize(filename)

      end
    end
    extend self

    def read(filename)
      ::HamlLint::RubyExtractor.new.extract(::HamlLint::Document.new(File.read(filename), { config: {} })).source
    end

    def read_verbose(filename)
      puts '```'
      puts File.read(filename)
      x = ::HamlLint::RubyExtractor.new.extract(::HamlLint::Document.new(File.read(filename), { config: {} })).source
      puts '```'
      puts x
      puts '```'
      x
    end
  end
end
