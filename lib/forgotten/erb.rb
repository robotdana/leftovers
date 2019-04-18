require 'erb'

module Forgotten
  class ERB < ::ERB::Compiler
    def add_insert_cmd(out, content)
      out.push("#{content}\n")
    end

    def add_put_cmd(out, content)
      out
    end
  end
end
