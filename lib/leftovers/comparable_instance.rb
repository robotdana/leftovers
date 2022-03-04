# frozen_string_literal: true

module Leftovers
  module ComparableInstance
    def eql?(other)
      frozen? && other.frozen? &&
        self.class == other.class &&
        instance_variables.all? do |var|
          instance_variable_get(var) == other.instance_variable_get(var)
        end
    end
    alias_method :==, :eql?

    def hash
      self.class.hash
    end
  end
end
