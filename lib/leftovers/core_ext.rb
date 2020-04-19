# frozen_string_literal: true

require 'set'

class Array
  def leftovers_append(other)
    case other
    when Array, Set then concat(other)
    when nil then self
    else self.<< other
    end
  end
end
