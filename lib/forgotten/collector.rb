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
    end

    def collect
      Forgotten::FileList.new.each do |filename|
        @current_filename = filename.delete_prefix(Dir.pwd + '/')
        file = File.read(filename)

        case File.extname(filename)
        when '.haml'
          require 'haml'
          file = Haml::Engine.new(file).precompiled
        when '.rhtml', '.rjs', '.erb'
          require_relative './erb'
          @erb_compiler ||= Forgotten::ERB.new('-')
          file = @erb_compiler.compile(File.read(filename)).first
        end

        parse_and_process(file)
      rescue Parser::SyntaxError => e
        puts "#{e.class}: #{e.message} #{filename}:#{e.diagnostic.location.line}:#{e.diagnostic.location.column}"
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
      collect_if_method_caller(node)
      collect_if_method_list_caller(node)
    end
    alias_method :on_const, :on_send

    # grab the :to_s in each(&:to_s)
    def on_block_pass(node)
      super

      if node.children[0].type == :sym
        calls << node.children[0].children[0]
      end
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
      collect_if_symbol_key_scoped_reference_caller(node)
    end

    private

    def collect_reference(node)
      return unless node
      return unless [:sym, :str].include?(node.type)

      parse_and_process(node.children.first.to_s)
    end

    # like 'controller#action'
    def collect_scoped_reference(node)
      return unless node
      return unless [:sym, :str].include?(node.type)

      calls << node.children.first.to_s.split('#', 2)[1].to_sym
    end

    def collect_if_symbol_key_caller(node)
      return unless Forgotten.config.symbol_key_callers.include?(node.children.first.children.first)

      collect_reference(node.children[1])
    end

    def collect_if_symbol_key_list_caller(node)
      return unless Forgotten.config.symbol_key_callers.include?(node.children.first.children.first)

      if node.children[1].type == :array
        node.children[1].children.each do |sub_node|
          collect_reference(sub_node)
        end
      end
    end

    def collect_if_symbol_key_scoped_reference_caller(node)
      return unless Forgotten.config.symbol_key_scoped_reference_callers.include?(node.children.first.children.first)

      collect_scoped_reference(node.children[1])
    end
    # grab calls to `send(:method), send('method')`
    def collect_if_method_caller(node)
      return unless Forgotten.config.method_callers.include?(node.children[1])
      collect_reference(node.children[2])
    end

    # grab calls to `before_action :method1, :method2`
    def collect_if_method_list_caller(node)
      return unless Forgotten.config.method_list_callers.include?(node.children[1])

      node.children.drop(2).each do |sub_node|
        collect_reference(sub_node)
      end
    end
  end
end
