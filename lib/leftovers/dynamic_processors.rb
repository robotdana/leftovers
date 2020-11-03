# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    autoload(:CallDefinition, "#{__dir__}/dynamic_processors/call_definition")
    autoload(:Call, "#{__dir__}/dynamic_processors/call")
    autoload(:Definition, "#{__dir__}/dynamic_processors/definition")
    autoload(:Each, "#{__dir__}/dynamic_processors/each")
    autoload(:Null, "#{__dir__}/dynamic_processors/null")
  end
end
