require 'fast_ignore'
require 'set'
require 'parser'
require 'parser/current'

module Forgotten
  class FileCollector < Parser::AST::Processor
    attr_reader :calls
    attr_reader :definitions

    def initialize(filename)
      @calls = []
      @definitions = []
      @path = filename
    end

    def filename
      @filename ||= @path.delete_prefix(Dir.pwd + '/')
    end

    def to_h
      {
        test?: test?,
        calls: calls,
        definitions: definitions
      }
    end

    def test?
      return @test if defined?(@test)

      @test = Forgotten.config.test_paths.allowed?(filename)
    end

    def collect
      ruby = preprocess_file
      parse_and_process(ruby)

    rescue Parser::SyntaxError => e
      puts "#{e.class}: #{e.message} #{filename}:#{e.diagnostic.location.line}:#{e.diagnostic.location.column}"
    end

    def preprocess_file
      file = File.read(filename)

      case File.extname(filename)
      when '.haml'
        Forgotten.try_require('haml', "Tried parsing a haml file, but the haml gem was not available\n`gem install haml`")
        if defined?(Haml)
          begin
            Haml::Engine.new(file).precompiled
          rescue Haml::SyntaxError => e
            puts "#{e.class}: #{e.message} #{filename}:#{e.line}"
            ''
          end
        else
          ''
        end
      when '.rhtml', '.rjs', '.erb'
        require_relative './erb'
        @erb_compiler ||= Forgotten::ERB.new('-')
        @erb_compiler.compile(file).first
      else
        file
      end
    end

    def parse_and_process(ruby)
      ast, comments = Parser::CurrentRuby.parse_with_comments(ruby)
      process(ast)
      process_comments(comments)
    end

    METHOD_NAME_RE = /[[:lower:]_][[:alnum:]_]*\b[\?!=]?/.freeze
    NON_ALNUM_METHOD_NAME_RE = Regexp.union(%w{
      []= [] ** ~ +@ -@ * / % + - >> << &
      ^ | <=> <= >= < > === == != =~ !~ !
    }.map { |op| /#{Regexp.escape(op)}/ })
    CONSTANT_NAME_RE = /[[:upper:]][[:alnum:]_]*\b/.freeze
    NAME_RE = Regexp.union(METHOD_NAME_RE, NON_ALNUM_METHOD_NAME_RE, CONSTANT_NAME_RE)
    LEFTOVERS_RE = /\bleftovers:(?:call|allow) (#{NAME_RE}(?:[, :]+#{NAME_RE})*)/.freeze
    def process_comments(comments)
      comments.each do |comment|
        match = comment.text.match(LEFTOVERS_RE)

        next unless match
        next unless match[1]

        match[1].scan(NAME_RE).each { |s| add_call(s.to_sym) }
      end
    end

    # grab method definitions
    def on_def(node)
      add_definition(node.children.first, node.loc.name)

      super
    end

    def on_ivasgn(node)
      add_definition(node.children.first, node.loc.name)

      super
    end

    def on_ivar(node)
      add_call(node.children.first)

      super
    end

    def on_op_asgn(node)
      collect_op_asgn(node)

      super
    end

    def on_and_asgn(node)
      collect_op_asgn(node)

      super
    end

    def on_or_asgn(node)
      collect_op_asgn(node)

      super
    end

    # grab method calls
    def on_send(node)
      super

      add_call(node.children[1])

      collect_method_rules(node)
    rescue StandardError => e
      puts "#{e.message} #{filename}:#{node.loc.expression}"
      raise
    end
    alias_method :on_const, :on_send
    alias_method :on_csend, :on_send

    # grab e.g. :to_s in each(&:to_s)
    def on_block_pass(node)
      super

      collect_symbol_call(node.children.first)
    end

    # grab class Constant or module Constant
    def on_class(node)
      # don't call super so we don't process the class name (# wtf does this mean dana? what would happen instead?)
      process_all(node.children.drop(1))

      node = node.children.first

      add_definition(node.children[1], node.loc.name)
    end
    alias_method :on_module, :on_class

    # grab Constant = Class.new or CONSTANT = 'string'.freeze
    def on_casgn(node)
      super

      add_definition(node.children[1], node.loc.name)
    end

    def add_definition(name, loc)
      definitions << Definition.new(name, loc, filename: filename, test: test?)
    end

    def add_call(name)
      calls << name
    end

    # grab calls to `alias new_method original_method`
    def on_alias(node)
      super

      new_method, original_method = node.children

      add_definition(new_method.children.first, new_method.loc.expression)
      add_call(original_method.children.first)
    end

    private

    def collect_op_asgn(node)
      node = node.children.first
      name = case node.type
      when :send
        node.children[1]
      when :ivasgn
        node.children.first
      end

      return unless name

      add_call(name)
      add_call(:"#{name}=")
    end

    def collect_symbol_call(node)
      return unless node
      return unless [:sym, :str].include?(node.type)

      add_call(node.children.first)
    end

    def collect_method_rules(node)
      node = MethodNode.new(node)

      Forgotten.config.rules.each do |rule|
        next unless rule.match?(node, filename)

        calls.concat(rule.calls(node))
        definitions.concat(
          rule.definitions(node).each do |d|
            d.filename = filename
            d.test = test?
          end
        )
      end
    end
  end
end
