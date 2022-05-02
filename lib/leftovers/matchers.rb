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
    autoload(:NodeHasAnyReceiver, "#{__dir__}/matchers/node_has_any_receiver")
    autoload(
      :NodeHasPositionalArgumentWithValue,
      "#{__dir__}/matchers/node_has_positional_argument_with_value"
    )
    autoload(:NodeHasPositionalArgument, "#{__dir__}/matchers/node_has_positional_argument")
    autoload(:NodeHasReceiver, "#{__dir__}/matchers/node_has_receiver")
    autoload(:NodeIsProc, "#{__dir__}/matchers/node_is_proc")
    autoload(:NodeName, "#{__dir__}/matchers/node_name")
    autoload(:NodePairKey, "#{__dir__}/matchers/node_pair_key")
    autoload(:NodePairValue, "#{__dir__}/matchers/node_pair_value")
    autoload(:NodePath, "#{__dir__}/matchers/node_path")
    autoload(:NodePrivacy, "#{__dir__}/matchers/node_privacy")
    autoload(:NodeScalarValue, "#{__dir__}/matchers/node_scalar_value")
    autoload(:NodeType, "#{__dir__}/matchers/node_type")
    autoload(:Not, "#{__dir__}/matchers/not")
    autoload(:Or, "#{__dir__}/matchers/or")
    autoload(:Path, "#{__dir__}/matchers/path")
  end
end
