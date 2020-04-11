# frozen_string_literal: true

require 'fast_ignore'
require 'set'
require 'parser'
require 'parser/current'
require_relative 'node'
require_relative 'erb'
require_relative 'haml'
require_relative 'definition'

module Leftovers
  class FileCollector < Parser::AST::Processor # rubocop:disable Metrics/ClassLength
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

      @test = Leftovers.config.test_paths.allowed?(filename)
    end

    def collect
      ruby = preprocess_file
      parse_and_process(ruby)
    rescue Parser::SyntaxError => e
      Leftovers.warn "#{e.class}: #{e.message} #{filename}:#{e.diagnostic.location.line}:#{e.diagnostic.location.column}" # rubocop:disable Metrics/LineLength
    end

    def preprocess_file # rubocop:disable Metrics/MethodLength
      file = File.read(filename)

      case File.extname(filename)
      when '.haml'
        Leftovers::Haml.precompile(file)
      when '.rhtml', '.rjs', '.erb'
        Leftovers::ERB.precompile(file)
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
    def process_comments(comments) # rubocop:disable Metrics/MethodLength
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
    alias_method :on_gvasgn, :on_ivasgn
    alias_method :on_cvasgn, :on_ivasgn

    def on_ivar(node)
      add_call(node.children.first)

      super
    end
    alias_method :on_gvar, :on_ivar
    alias_method :on_cvar, :on_ivar

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
    def on_send(node) # rubocop:disable Metrics/MethodLength
      super

      add_call(node.children[1])

      collect_method_rules(node)
    rescue StandardError => e
      puts "#{e.message} #{filename}:#{node.loc.expression}"
      raise
    end
    alias_method :on_csend, :on_send

    def on_const(node)
      super

      add_call(node.children[1])
    end

    # grab e.g. :to_s in each(&:to_s)
    def on_block_pass(node)
      super

      add_call(node.children.first.to_sym) if node.children.first&.string_or_symbol?
    end

    # grab class Constant or module Constant
    def on_class(node)
      # don't call super so we don't process the class name
      # !!! (# wtf does this mean dana? what would happen instead?)
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
      definitions << Leftovers::Definition.new(name, loc, filename: filename, test: test?)
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

    # just collects the call, super will collect the definition
    def collect_var_op_asgn(node)
      name = node.children.first

      return unless name

      add_call(name)
    end

    def collect_send_op_asgn(node)
      name = node.children[1]

      return unless name

      add_call(name)
      add_call(:"#{name}=")
    end

    def collect_op_asgn(node)
      node = node.children.first
      case node.type
      when :send then collect_send_op_asgn(node)
      when :ivasgn, :gvasgn, :cvasgn then collect_var_op_asgn(node)
      end
    end

    def collect_method_rules(node) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      Leftovers.config.rules.each do |rule|
        next unless rule.match?(node.to_s, filename)
        next if rule.skip?

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
