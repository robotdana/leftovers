require 'erb'

module Leftovers
  class ERB < ::ERB::Compiler

    def self.precompile(erb)
      @compiler ||= new('-')
      @compiler.compile(erb).first
    end

    def add_insert_cmd(out, content)
      out.push("#{content}\n")
    end

    def add_put_cmd(out, content)
      out
    end
  end
end
