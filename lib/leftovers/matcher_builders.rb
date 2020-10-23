# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    autoload(:AndNot, "#{__dir__}/matcher_builders/and_not")
    autoload(:And, "#{__dir__}/matcher_builders/and")
    autoload(:Keep, "#{__dir__}/matcher_builders/keep")
    autoload(:Name, "#{__dir__}/matcher_builders/name")
    autoload(:NodeHasArgument, "#{__dir__}/matcher_builders/node_has_argument")
    autoload(:NodeHasKeywordArgument, "#{__dir__}/matcher_builders/node_has_keyword_argument")
    autoload(:NodeHasPositionalArgument, "#{__dir__}/matcher_builders/node_has_positional_argument")
    autoload(:NodeName, "#{__dir__}/matcher_builders/node_name")
    autoload(:NodePath, "#{__dir__}/matcher_builders/node_path")
    autoload(:NodeType, "#{__dir__}/matcher_builders/node_type")
    autoload(:Node, "#{__dir__}/matcher_builders/node")
    autoload(:Or, "#{__dir__}/matcher_builders/or")
    autoload(:Path, "#{__dir__}/matcher_builders/path")
    autoload(:Rule, "#{__dir__}/matcher_builders/rule")
    autoload(:StringPattern, "#{__dir__}/matcher_builders/string_pattern")
    autoload(:String, "#{__dir__}/matcher_builders/string")
    autoload(:Unless, "#{__dir__}/matcher_builders/unless")
  end
end
