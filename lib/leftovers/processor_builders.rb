# frozen-string-literal: true

module Leftovers
  module ProcessorBuilders
    autoload(:Action, "#{__dir__}/processor_builders/action")
    autoload(:AddPrefix, "#{__dir__}/processor_builders/add_prefix")
    autoload(:AddSuffix, "#{__dir__}/processor_builders/add_suffix")
    autoload(:Argument, "#{__dir__}/processor_builders/argument")
    autoload(:Dynamic, "#{__dir__}/processor_builders/dynamic")
    autoload(:EachAction, "#{__dir__}/processor_builders/each_action")
    autoload(:EachDynamic, "#{__dir__}/processor_builders/each_dynamic")
    autoload(:EachForDefinitionSet, "#{__dir__}/processor_builders/each_for_definition_set")
    autoload(:Each, "#{__dir__}/processor_builders/each")
    autoload(:Itself, "#{__dir__}/processor_builders/itself")
    autoload(:Keyword, "#{__dir__}/processor_builders/keyword")
    autoload(:KeywordArgument, "#{__dir__}/processor_builders/keyword_argument")
    autoload(:TransformChain, "#{__dir__}/processor_builders/transform_chain")
    autoload(:TransformSet, "#{__dir__}/processor_builders/transform_set")
    autoload(:Transform, "#{__dir__}/processor_builders/transform")
    autoload(:Value, "#{__dir__}/processor_builders/value")
  end
end
