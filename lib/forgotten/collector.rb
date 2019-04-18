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

        case File.extname(filename)
        when '.haml'
          Forgotten::Haml.new(filename, self)
        else
          parse_and_process(File.read(filename))
        end
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
      definitions << [node.children.first, node.loc.name, @current_filename.delete_prefix(Dir.pwd + '/')]

      super
    end

    def on_send(node)
      calls << node.children[1]

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
