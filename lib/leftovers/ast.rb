# frozen-string-literal: true

module Leftovers
  module AST
    autoload(:ArrayNode, "#{__dir__}/ast/array_node")
    autoload(:BlockNode, "#{__dir__}/ast/block_node")
    autoload(:Builder, "#{__dir__}/ast/builder")
    autoload(:CasgnNode, "#{__dir__}/ast/casgn_node")
    autoload(:ConstNode, "#{__dir__}/ast/const_node")
    autoload(:DefNode, "#{__dir__}/ast/def_node")
    autoload(:DefsNode, "#{__dir__}/ast/defs_node")
    autoload(:FalseNode, "#{__dir__}/ast/false_node")
    autoload(:HashNode, "#{__dir__}/ast/hash_node")
    autoload(:HasArguments, "#{__dir__}/ast/has_arguments")
    autoload(:ModuleNode, "#{__dir__}/ast/module_node")
    autoload(:NilNode, "#{__dir__}/ast/nil_node")
    autoload(:Node, "#{__dir__}/ast/node")
    autoload(:NumericNode, "#{__dir__}/ast/numeric_node")
    autoload(:SendNode, "#{__dir__}/ast/send_node")
    autoload(:StrNode, "#{__dir__}/ast/str_node")
    autoload(:SymNode, "#{__dir__}/ast/sym_node")
    autoload(:TrueNode, "#{__dir__}/ast/true_node")
    autoload(:VasgnNode, "#{__dir__}/ast/vasgn_node")
    autoload(:VarNode, "#{__dir__}/ast/var_node")
  end
end
