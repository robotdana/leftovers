require 'haml'

module Forgotten
  class Haml
    attr_reader :collector
    def initialize(filename, collector)
      @string = ''
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
        node.children.each { |child| visit(child) }
      end

    end

    def add_line(line)
      @string << line + "\n"
    end

    def visit_script(node)
      add_line(node.text)
      node.children.each { |child| visit(child) }
      add_line('end') if start_block?
    end

    def start_block?(node)
      anonymous_block?(node.text) || start_block_keyword?(node.text)
    end

    def visit_filter(node)
      return unless node.value[:name] == "ruby"

      add_line(node.text)
    end

    def visit_tag(node)
      return unless node.value[:dynamic_attributes].old

      add_line(node.value[:dynamic_attributes].old)
    end

    # The following is copied dierctly from haml-lint
    def anonymous_block?(text)
      text =~ /\bdo\s*(\|\s*[^\|]*\s*\|)?(\s*#.*)?\z/
    end

    START_BLOCK_KEYWORDS = %w[if unless case begin for until while].freeze
    def start_block_keyword?(text)
      START_BLOCK_KEYWORDS.include?(block_keyword(text))
    end

    MID_BLOCK_KEYWORDS = %w[else elsif when rescue ensure].freeze
    # leftovers:allow mid_block_keyword?
    def mid_block_keyword?(text)
      MID_BLOCK_KEYWORDS.include?(block_keyword(text))
    end

    LOOP_KEYWORDS = %w[for until while].freeze
    def block_keyword(text)
      # Need to handle 'for'/'while' since regex stolen from HAML parser doesn't
      if keyword = text[/\A\s*([^\s]+)\s+/, 1]
        return keyword if LOOP_KEYWORDS.include?(keyword)
      end

      return unless keyword = text.scan(Haml::Parser::BLOCK_KEYWORD_REGEX)[0]
      keyword[0] || keyword[1]
    end
  end
end
