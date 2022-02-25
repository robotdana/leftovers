# frozen_string_literal: true

require 'set'

module Leftovers
  class FileCollector
    autoload(:CommentsProcessor, "#{__dir__}/file_collector/comments_processor.rb")
    autoload(:NodeProcessor, "#{__dir__}/file_collector/node_processor.rb")

    attr_reader :calls, :allow_lines, :test_lines, :dynamic_lines
    attr_accessor :default_method_privacy

    def initialize(ruby, file)
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
      { test?: @file.test?, calls: squash!(calls), definitions: squash!(definitions) }
    end

    def squash!(list)
      list.flatten!
      list.compact!
      list.uniq!
      list
    end

    def collect
      ast, comments = Leftovers::Parser.parse_with_comments(@ruby, @file.relative_path)
      CommentsProcessor.process(comments, self)
      NodeProcessor.new(self).process(ast)
    rescue ::Parser::SyntaxError => e
      Leftovers.warn(
        "\e[31m#{filename}:#{e.diagnostic.location.line}:#{e.diagnostic.location.column} " \
          "SyntaxError: #{e.message}\e[0m"
      )
    end

    # grab method definitions
    def add_definition(node, name: node.name, loc: node.loc.name)
      @definitions_to_add[name] = ::Leftovers::DefinitionToAdd.new(node, name: name, location: loc)
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
      @definitions ||= @definitions_to_add.each_value.map { |d| d.to_definition(self) } +
        @definition_sets_to_add.map do |definition_set|
          next if definition_set.any? { |d| d.keep?(self) }

          ::Leftovers::DefinitionSet.new(definition_set.map { |d| d.to_definition(self) })
        end
    end

    def test_line?(line)
      @file.test? || @test_lines.include?(line)
    end

    def keep_line?(line)
      @allow_lines.include?(line)
    end

    def add_call(name)
      calls << name
    end

    def collect_send(node)
      add_call(node.name)
      collect_dynamic(node)
    end

    def collect_variable_assign(node)
      add_definition(node)
      collect_dynamic(node)
    end

    def collect_op_asgn(node)
      node = node.first
      case node.type
      # just collects the :call=, super will collect the :call
      when :send, :csend then add_call(:"#{node.name}=")
      # just collects the call, super will collect the definition
      when :ivasgn, :gvasgn, :cvasgn then add_call(node.name)
      when :lvasgn then nil # we don't care about lvasgn
      # :nocov:
      else raise Leftovers::UnexpectedCase, "Unhandled value #{node.type.inspect}"
        # :nocov:
      end
    end

    def collect_commented_dynamic(node)
      @dynamic_lines[node.loc.line]&.each do |fake_method_name|
        collect_dynamic(build_send_wrapper_for(node, fake_method_name))
      end
    end

    def collect_dynamic(node)
      node.keep_line = @allow_lines.include?(node.loc.line)

      Leftovers.config.dynamic.process(node, self)
    rescue StandardError => e
      raise ::Leftovers::Error, "#{e.class}: #{e.message}\n" \
        "when processing #{node} at #{filename}:#{node.loc.line}:#{node.loc.column}", e.backtrace
    end

    private

    def build_send_wrapper_for(node, name)
      ::Leftovers::AST::Node.new(
        :send, [nil, name.to_sym, *node.arguments], location: node.location
      )
    end
  end
end
