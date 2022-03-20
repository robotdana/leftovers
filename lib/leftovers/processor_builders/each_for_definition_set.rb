# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    class EachForDefinitionSet < Each
      class << self
        private

        def processor_class
          Processors::EachForDefinitionSet
        end
      end
    end
  end
end
