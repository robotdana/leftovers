module Forgotten
  class Reporter
    def call(name, loc, filename)
      puts "\033[36m#{filename}:#{loc.line}:#{loc.column} \033[0m#{name}"
    end
  end
end
