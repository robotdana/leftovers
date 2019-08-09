module Forgotten
  class Reporter
    def call(definition)
      puts "\033[36m#{definition.filename}:#{definition.location.line}:#{definition.location.column} \033[0m#{definition.name}"
    end
  end
end
