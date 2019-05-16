require 'erb'

class ::ERB
  class Compiler
    def add_insert_cmd(out, content)
      out.push("#{content}\n")
    end

    def add_put_cmd(out, content)
      out
    end
  end
end

module Forgotten
  module ERB
    extend self

    def read(filename)
      compiler.compile(File.read(filename)).first
    end

    private

    def compiler
      @compiler ||= ::ERB::Compiler.new('-')
    end
  end
end
