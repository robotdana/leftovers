# frozen_string_literal: true

require 'set'

class Array
  def leftovers_append(other) # rubocop:disable Metrics/MethodLength
    return self if other.nil?

    if other.respond_to?(:to_a)
      concat(other.to_a)
    else
      self << other
    end
  end
end
