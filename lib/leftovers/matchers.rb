# frozen-string-literal: true

module Leftovers
  module Matchers
    autoload(:All, "#{__dir__}/matchers/all")
    autoload(:And, "#{__dir__}/matchers/and")
    autoload(:Any, "#{__dir__}/matchers/any")
    autoload(:NodeHasAnyKeywordArgument, "#{__dir__}/matchers/node_has_any_keyword_argument")
    autoload(
      :NodeHasAnyPositionalArgumentWithValue,
      "#{__dir__}/matchers/node_has_any_positional_argument_with_value"
    )
    autoload(
      :NodeHasPositionalArgumentWithValue,
      "#{__dir__}/matchers/node_has_positional_argument_with_value"
    )
    autoload(:NodeHasPositionalArgument, "#{__dir__}/matchers/node_has_positional_argument")
    autoload(:NodeName, "#{__dir__}/matchers/node_name")
    autoload(:NodePairValue, "#{__dir__}/matchers/node_pair_value")
    autoload(:NodePath, "#{__dir__}/matchers/node_path")
    autoload(:NodeScalarValue, "#{__dir__}/matchers/node_scalar_value")
    autoload(:NodeType, "#{__dir__}/matchers/node_type")
    autoload(:Not, "#{__dir__}/matchers/not")
    autoload(:Or, "#{__dir__}/matchers/or")
  end
end
