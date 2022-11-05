# frozen-string-literal: true

require 'parser'

module Leftovers
  class FileCollector
    class NodeProcessor < ::Parser::AST::Processor
      def initialize(collector) # rubocop:disable Lint/MissingSuper # there isn't one to call
        @collector = collector
      end

      def on_def(node)
        node.privacy = @collector.default_method_privacy
        @collector.add_definition(node)
        super
      end

      def on_defs(node)
        @collector.add_definition(node)
        super
      end

      def on_ivasgn(node)
        @collector.collect_variable_assign(node)
        super
      end

      def on_gvasgn(node)
        @collector.collect_variable_assign(node)
        super
      end

      def on_cvasgn(node)
        @collector.collect_variable_assign(node)
        super
      end

      def on_ivar(node)
        @collector.calls << node.name
        super
      end

      def on_gvar(node)
        @collector.calls << node.name
        super
      end

      def on_cvar(node)
        @collector.calls << node.name
        super
      end

      def on_op_asgn(node)
        @collector.collect_op_asgn(node)
        super
      end

      def on_and_asgn(node)
        @collector.collect_op_asgn(node)
        super
      end

      def on_or_asgn(node)
        @collector.collect_op_asgn(node)
        super
      end

      def on_send(node)
        super
        @collector.collect_send(node)
      end

      def on_csend(node)
        super
        @collector.collect_send(node)
      end

      def on_const(node)
        super
        @collector.calls << node.name
      end

      def on_array(node)
        super
        @collector.collect_commented_dynamic(node)
      end

      def on_hash(node)
        super
        @collector.collect_commented_dynamic(node)
      end

      # why are block args the parent of send/csend
      def on_block(node)
        node.first.parent = node

        super
      end

      # grab e.g. :to_s in each(&:to_s)
      def on_block_pass(node)
        super
        return unless node.first.sym?

        @collector.calls << node.first.to_sym
      end

      # grab class Constant or module Constant
      def on_class(node)
        # don't call super so we don't interpret the class name as being called by its definition
        process_all(node.children.drop(1))

        node = node.children.first

        @collector.add_definition(node)
      end
      alias_method :on_module, :on_class

      # grab Constant = Class.new or CONSTANT = 'string'.freeze
      # or Constant ||= Class.new
      def on_casgn(node)
        super

        @collector.add_definition(node)
        @collector.collect_dynamic(node)
      end

      # grab calls to `alias new_method original_method`
      def on_alias(node)
        super
        new_method, original_method = node.children
        @collector.add_definition(
          new_method, name: new_method.children.first, loc: new_method.loc.expression
        )
        @collector.calls << original_method.children.first
      end
    end
  end
end
