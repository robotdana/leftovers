# frozen_string_literal: true

require 'erb'

module Leftovers
  module Precompilers
    class ERB < ::ERB::Compiler
      def self.precompile(erb)
        @compiler ||= new('-')
        @compiler.compile(erb).first
      end

      def add_insert_cmd(out, content) # leftovers:keep
        out.push("\n#{content}\n")
      end

      def add_put_cmd(out, _content) # leftovers:keep
        out.push("\n")
      end
    end
  end
end
