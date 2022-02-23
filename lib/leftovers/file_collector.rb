# frozen_string_literal: true

require 'set'
require 'parser'

module Leftovers
  class FileCollector < ::Parser::AST::Processor # rubocop:disable Metrics/ClassLength
    attr_reader :calls
    attr_accessor :default_method_privacy

    def initialize(ruby, file) # rubocop:disable Lint/MissingSuper
      @calls = []
      @definitions_to_add = {}
      @allow_lines = Set.new.compare_by_identity
      @test_lines = Set.new.compare_by_identity
      @dynamic_lines = {}
      @ruby = ruby
      @file = file
      @default_method_privacy = :public
      @definition_sets_to_add = []
    end

    def filename
      @filename ||= @file.relative_path
    end

    def to_h
      squash!

      {
        test?: @file.test?,
        calls: calls,
        definitions: definitions
      }
    end

    def squash!
      calls.flatten!
      calls.compact!
      calls.uniq!
      definitions.flatten!
      definitions.compact!
      definitions.uniq!
    end

    def collect
      ast, comments = Leftovers::Parser.parse_with_comments(@ruby, @file.relative_path)
      process_comments(comments)
      process(ast)
    rescue ::Parser::SyntaxError => e
      Leftovers.warn "\e[31m#{filename}:#{e.diagnostic.location.line}:#{e.diagnostic.location.column} SyntaxError: #{e.message}\e[0m" # rubocop:disable Layout/LineLength
    end

    METHOD_NAME_RE = /[[:alpha:]_][[:alnum:]_]*\b[?!=]?/.freeze
    NON_ALNUM_METHOD_NAME_RE = Regexp.union(%w{
      []= [] ** ~ +@ -@ * / % + - >> << &
      ^ | <=> <= >= < > === == != =~ !~ !
    }.map { |op| /#{Regexp.escape(op)}/ })
    CONSTANT_NAME_RE = /[[:upper:]][[:alnum:]_]*\b/.freeze
    NAME_RE = Regexp.union(METHOD_NAME_RE, NON_ALNUM_METHOD_NAME_RE, CONSTANT_NAME_RE)
    LEFTOVERS_CALL_RE = /\bleftovers:call(?:s|ed|er|ers|) (#{NAME_RE}(?:[, :]+#{NAME_RE})*)/.freeze
    LEFTOVERS_ALLOW_RE = /\bleftovers:(?:keeps?|skip(?:s|ped|)|allow(?:s|ed|))\b/.freeze
    LEFTOVERS_TEST_RE = /\bleftovers:(?:for_tests?|tests?|testing|test_only)\b/.freeze
    LEFTOVERS_DYNAMIC_RE = /\bleftovers:dynamic:(#{NAME_RE})\b/.freeze

    def process_comments(comments) # rubocop:disable Metrics/AbcSize
      comments.each do |comment|
        @allow_lines << comment.loc.line if comment.text.match?(LEFTOVERS_ALLOW_RE)
        @test_lines << comment.loc.line if comment.text.match?(LEFTOVERS_TEST_RE)
        dynamic_match = comment.text.match(LEFTOVERS_DYNAMIC_RE)
        @dynamic_lines[comment.loc.line] = dynamic_match[1] if dynamic_match

        next unless (call_match = comment.text.match(LEFTOVERS_CALL_RE))

        call_match[1].scan(NAME_RE).each { |s| add_call(s.to_sym) }
      end
    end

    # grab method definitions
    def on_def(node)
      node.privacy = default_method_privacy
      add_definition(node)
      super
    end

    def on_defs(node)
      add_definition(node)
      super
    end

    def on_ivasgn(node)
      collect_variable_assign(node)
      super
    end

    def on_gvasgn(node)
      collect_variable_assign(node)
      super
    end

    def on_cvasgn(node)
      collect_variable_assign(node)
      super
    end

    def on_ivar(node)
      add_call(node.name)
      super
    end

    def on_gvar(node)
      add_call(node.name)
      super
    end

    def on_cvar(node)
      add_call(node.name)
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
      collect_send(node)
    end

    def on_csend(node)
      super
      collect_send(node)
    end

    def on_const(node)
      super
      add_call(node.name)
    end

    def on_array(node)
      super
      collect_commented_dynamic(node)
    end

    def on_hash(node)
      super
      collect_commented_dynamic(node)
    end

    # grab e.g. :to_s in each(&:to_s)
    def on_block_pass(node)
      super
      add_call(node.children.first.to_sym) if node.children.first.string_or_symbol?
    end

    # grab class Constant or module Constant
    def on_class(node)
      # don't call super so we don't process the class name
      # !!! (# wtf does this mean dana? what would happen instead?)
      process_all(node.children.drop(1))

      node = node.children.first

      add_definition(node)
    end
    alias_method :on_module, :on_class

    # grab Constant = Class.new or CONSTANT = 'string'.freeze
    def on_casgn(node)
      super
      add_definition(node)
      collect_dynamic(node)
    end

    # grab calls to `alias new_method original_method`
    def on_alias(node)
      super
      new_method, original_method = node.children
      add_definition(new_method, name: new_method.children.first, loc: new_method.loc.expression)
      add_call(original_method.children.first)
    end

    def add_definition(node, name: node.name, loc: node.loc.name)
      @definitions_to_add[name] =
        ::Leftovers::DefinitionToAdd.new(node, name: name, location: loc)
    end

    def add_definition_set(definition_node_set)
      @definition_sets_to_add << definition_node_set.definitions.map do |definition_node|
        ::Leftovers::DefinitionToAdd.new(definition_node, location: definition_node.loc)
      end
    end

    def set_privacy(name, to)
      @definitions_to_add[name]&.privacy = to
    end

    def definitions
      @definitions ||= @definitions_to_add.each_value.map { |d| d.to_definition(self) }.compact +
        @definition_sets_to_add.map do |definition_set|
          next nil if definition_set.any? { |d| d.keep?(self) }

          ::Leftovers::DefinitionSet.new(definition_set.map { |d| d.to_definition(self) })
        end.compact
    end

    def test_line?(line)
      @file.test? ||
        @test_lines.include?(line)
    end

    def keep_line?(line)
      @allow_lines.include?(line)
    end

    private

    def add_call(name)
      calls << name
    end

    def collect_send(node)
      add_call(node.name)
      collect_dynamic(node)
    end

    # just collects the call, super will collect the definition
    def collect_var_op_asgn(node)
      name = node.children.first

      add_call(name)
    end

    def collect_send_op_asgn(node)
      name = node.children[1]

      add_call(:"#{name}=")
    end

    def collect_variable_assign(node)
      add_definition(node)

      collect_dynamic(node)
    end

    def collect_op_asgn(node)
      node = node.children.first
      case node.type
      when :send then collect_send_op_asgn(node)
      when :ivasgn, :gvasgn, :cvasgn then collect_var_op_asgn(node)
      when :lvasgn then nil # we don't care about lvasgn
      # :nocov:
      else
        raise "Unrecognized op_asgn node type #{node.type}"
        # :nocov:
      end
    end

    def collect_commented_dynamic(node)
      fake_method_name = @dynamic_lines[node.loc.line]
      return unless fake_method_name

      node = build_send_wrapper_for(node, fake_method_name)
      collect_dynamic(node)
    end

    def build_send_wrapper_for(node, name)
      ::Leftovers::AST::Node.new(
        :send,
        [nil, name.to_sym, *node.arguments],
        location: node.location
      )
    end

    def collect_dynamic(node)
      node.keep_line = @allow_lines.include?(node.loc.line)

      Leftovers.config.dynamic.process(node, self)
    rescue StandardError => e
      raise ::Leftovers::Error, "#{e.class}: #{e.message}\nwhen processing #{node} at #{filename}:#{node.loc.line}:#{node.loc.column}", e.backtrace # rubocop:disable Layout/LineLength
    end
  end
end
