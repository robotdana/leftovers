# frozen_string_literal: true

require 'set'

class Array
  # concat, # push, # add, #
  EMPTY = [].freeze

  def gather(other)
    case other
    when Array, Set then concat(other)
    when nil then self
    else self.<< other
    end
  end

  def self.wrap(value)
    case value
    when nil then EMPTY
    when Array then value
    else [value]
    end
  end

  def self.each_or_self(value, &block)
    case value
    when nil then nil
    when Array then value.each(&block)
    else block.call(value)
    end
  end
end
