require 'fast_ignore'
require 'parser'
require 'parser/current'

module Forgotten
  class Collector < Parser::AST::Processor
    attr_reader :calls
    attr_reader :definitions

    def initialize
      @calls = []
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

      process_collected
    end

    def process_collected
      calls.sort!
      calls.uniq!
    end

    def called?(definition)
      calls.bsearch { |value| definition <=> value }
    end

    def preprocess_file(filename)
      file = File.read(filename)

      case File.extname(filename)
      when '.haml'
        require 'haml'
        Haml::Engine.new(file).precompiled
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
      definitions << [node.children.first, node.loc.name, @current_filename]

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

      definitions << [node.children.first.children[1], node.children.first.loc.name, @current_filename]
    end
    alias_method :on_module, :on_class

    # grab Constant = Class.new or CONSTANT = 'string'.freeze
    def on_casgn(node)
      super

      definitions << [node.children[1], node.loc.name, @current_filename]
    end

    def on_pair(node)
      super

      collect_if_symbol_key_caller(node)
      collect_if_symbol_key_list_caller(node)
    end

    # grab calls to `alias new_method original_method`
    def on_alias(node)
      super

      definitions << [node.children.first.children.first, node.children.first.loc.expression, @current_filename]
      calls << node.children[1].children.first
    end

    private

    def collect_symbol_definition(node)
      return unless node
      return unless [:sym, :str].include?(node.type)

      definitions << [node.children.first, node.loc.expression, @current_filename]
    end

    def collect_symbol_call(node)
      return unless node
      return unless [:sym, :str].include?(node.type)

      node.children.first.to_s.split(/[.:#]+/).each do |sub_node|
        calls << sub_node.to_sym
      end
    end

    # grab calls to `alias_method :new_method, :original_method`
    def collect_if_alias_method(node)
      return unless Forgotten.config.alias_method_callers.include?(node.children[1])

      collect_symbol_definition(node.children[2])
      collect_symbol_call(node.children[3])
    end

    # grab calls to `validate :presence if: :condition?`
    def collect_if_symbol_key_caller(node)
      return unless Forgotten.config.symbol_key_callers.include?(node.children.first.children.first)

      collect_symbol_call(node.children[1])
    end

    # grab calls to `validate :presence if: [:condition_one?, :condition_two?]`
    def collect_if_symbol_key_list_caller(node)
      return unless Forgotten.config.symbol_key_callers.include?(node.children.first.children.first)

      if node.children[1].type == :array
        node.children[1].children.each do |sub_node|
          collect_symbol_call(sub_node)
        end
      end
    end

    # grab calls to `send(:method), send('method')`
    def collect_if_method_caller(node)
      return unless Forgotten.config.method_callers.include?(node.children[1])
      collect_symbol_call(node.children[2])
    end

    # grab calls to `before_action :method1, :method2`
    def collect_if_method_list_caller(node)
      return unless Forgotten.config.method_list_callers.include?(node.children[1])

      node.children.drop(2).each do |sub_node|
        collect_symbol_call(sub_node)
      end
    end
  end
end
