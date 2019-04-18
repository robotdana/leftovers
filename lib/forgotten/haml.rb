module Forgotten
  class Haml
    attr_reader :collector
    def initialize(filename, collector)
      require 'haml'
      @collector = collector

      visit(::Haml::Parser.new({}).call(File.read(filename)))
    end

    def visit(node)
      case node.type
      when :script
        visit_script(node)
      when :silent_script
        visit_script(node)
      when :filter
        visit_filter(node)
      when :tag
        visit_tag(node)
      end

      node.children.each { |child| visit(child) }
    end

    def visit_script(node)
      collector.parse_and_process(node.value[:text])
    end

    def visit_filter(node)
      return unless node.value[:name] == "ruby"

      collector.parse_and_process(node.value[:text])
    end

    def visit_tag(node)
      return unless node.value[:dynamic_attributes]

      collector.parse_and_process(node.value[:dynamic_attributes].old)
    end
  end
end
