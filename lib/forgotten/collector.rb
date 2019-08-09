require 'fast_ignore'
require 'set'
require 'parser'
require 'parser/current'

module Forgotten
  class Collector < Parser::AST::Processor
    attr_reader :calls
    attr_reader :definitions

    def initialize
      @calls = Set.new
      @definitions = []
      @process_next = []
    end

    def collect
      Forgotten::FileList.new.each do |filename|
        @current_filename = filename.delete_prefix(Dir.pwd + '/')
        file = preprocess_file(filename)

        parse_and_process(file)
      rescue Parser::SyntaxError => e
        puts "#{e.class}: #{e.message} #{filename}:#{e.diagnostic.location.line}:#{e.diagnostic.location.column}"
      end
    end

    def preprocess_file(filename)
      file = File.read(filename)

      case File.extname(filename)
      when '.haml'
        Forgotten.try_require('haml', "Tried parsing a haml file, but the haml gem was not available\n`gem install haml`")
        defined?(Haml) ? Haml::Engine.new(file).precompiled : ''
      when '.rhtml', '.rjs', '.erb'
        require_relative './erb'
        @erb_compiler ||= Forgotten::ERB.new('-')
        @erb_compiler.compile(File.read(filename)).first
      else
        file
      end
    end

    def parse_and_process(ruby)
      process(Parser::CurrentRuby.parse(ruby))
    end

    # grab method definitions
    def on_def(node)
      definitions << Definition.new(node.children.first, node.loc.name, @current_filename)

      super
    end

    # grab method calls
    def on_send(node)
      super

      calls << node.children[1]
      # send, etc
      collect_if_alias_method(node)
      collect_if_method_caller(node)
      collect_if_method_list_caller(node)
      collect_if_method_hash_key_caller(node)
    end
    alias_method :on_const, :on_send

    # grab e.g. :to_s in each(&:to_s)
    def on_block_pass(node)
      super

      collect_symbol_call(node.children.first)
    end

    # grab class Constant or module Constant
    def on_class(node)
      # don't call super so we don't process the class name
      process_all(node.children.drop(1))

      definitions << Definition.new(node.children.first.children[1], node.children.first.loc.name, @current_filename)
    end
    alias_method :on_module, :on_class

    # grab Constant = Class.new or CONSTANT = 'string'.freeze
    def on_casgn(node)
      super

      definitions << Definition.new(node.children[1], node.loc.name, @current_filename)
    end

    def on_pair(node)
      super

      collect_if_symbol_key_caller(node)
      collect_if_symbol_key_list_caller(node)
    end

    # grab calls to `alias new_method original_method`
    def on_alias(node)
      super

      definitions << Definition.new(node.children.first.children.first, node.children.first.loc.expression, @current_filename)
      calls << node.children[1].children.first
    end

    private

    def collect_symbol_definition(node)
      return unless node
      return unless [:sym, :str].include?(node.type)

      definitions << Definition.new(node.children.first, node.loc.expression, @current_filename)
    end

    def collect_symbol_call(node, matcher = nil)
      return unless node
      return unless [:sym, :str].include?(node.type)

      node.children.first.to_s.split(/[.:]+/).each do |sub_node|
        calls << (matcher ? matcher.transform(sub_node).to_sym : sub_node.to_sym)
      end
    end

    # grab calls to `alias_method :new_method, :original_method`
    def collect_if_alias_method(node)
      caller = node.children[1]
      Forgotten.config.alias_method_callers.select do |matcher|
        next unless matcher.name == caller

        collect_symbol_definition(node.children[2])
        collect_symbol_call(node.children[3], matcher)
      end
    end

    # grab calls to `validate :presence if: :condition?`
    def collect_if_symbol_key_caller(node)
      caller = node.children.first.children.first
      callee = node.children[1]

      Forgotten.config.symbol_key_callers.each do |matcher|
        next unless matcher.name == caller

        collect_symbol_call(callee, matcher)
      end
    end

    # grab calls to `validate :presence if: [:condition_one?, :condition_two?]`
    def collect_if_symbol_key_list_caller(node)
      return unless node.children[1].type == :array

      caller = node.children.first.children.first
      callees = node.children[1].children
      Forgotten.config.symbol_key_list_callers.each do |matcher|
        next unless matcher.name == caller

        callees.each { |callee| collect_symbol_call(callee, matcher) }
      end
    end

    # grab calls to `send(:method), send('method')`
    def collect_if_method_caller(node)
      caller = node.children[1]
      callee = node.children[2]
      Forgotten.config.method_callers.each do |matcher|
        next unless matcher.name == caller

        collect_symbol_call(callee, matcher)
      end
    end

    # grab calls to `before_action :method1, :method2`
    def collect_if_method_list_caller(node)
      caller = node.children[1]
      callees = node.children.drop(2)

      Forgotten.config.method_list_callers.each do |matcher|
        next unless matcher.name == caller

        callees.each { |callee| collect_symbol_call(callee, matcher) }
      end
    end

    def collect_if_method_hash_key_caller(node)
      caller = node.children[1]
      callees = node.children.last

      return unless callees.type == :hash

      Forgotten.config.method_hash_key_callers.each do |matcher|
        next unless matcher.name == caller

        callees.children.each do |pair|
          collect_symbol_call(pair.children.first, matcher)
        end
      end
    end
  end
end
