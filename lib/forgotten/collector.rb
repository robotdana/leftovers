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

    def report
      definitions.reduce(0) do |exit_code, (name, loc, filename)|
        next exit_code if calls.include?(name)
        next exit_code if allowed?(name.to_s)

        puts "\033[36m#{filename}:#{loc.line}:#{loc.column} \033[0m#{name}"
        1
      end
    end

    def allowed?(name)
      Forgotten.config.allowed.any? { |pattern| name.match(pattern) }
    end

    def on_def(node)
      definitions << [node.children.first, node.loc.name, @current_filename]

      super
    end

    def collect_if_method_caller(node)
      return unless Forgotten.config.method_callers.include?(node.children[1])
      return unless [:sym, :str].include?(node.children[2].type)

      calls << node.children[2].children[0].to_sym
    end

    def on_send(node)
      calls << node.children[1]
      # send, etc
      collect_if_method_caller(node)
      super
    end
    alias_method :on_const, :on_send

    def on_class(node)
      definitions << [node.children.first.children[1], node.children.first.loc.name, @current_filename]
      # don't call super so we don't process the class name
      process_all(node.children.drop(1))
    end
    alias_method :on_module, :on_class

    def on_casgn(node)
      definitions << [node.children[1], node.loc.name, @current_filename]

      super
    end
  end
end
