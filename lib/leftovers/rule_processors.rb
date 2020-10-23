# frozen-string-literal: true

module Leftovers
  module RuleProcessors
    autoload(:CallDefinition, "#{__dir__}/rule_processors/call_definition")
    autoload(:Call, "#{__dir__}/rule_processors/call")
    autoload(:Definition, "#{__dir__}/rule_processors/definition")
    autoload(:Each, "#{__dir__}/rule_processors/each")
    autoload(:Null, "#{__dir__}/rule_processors/null")
  end
end
