module Leftovers
  class Reporter
    def call(definition)
      puts "\e[36m#{definition.full_location}\e[0m #{definition.name} \e[2m#{definition.highlighted_source("\e[33m", "\e[0;2m")}\e[0m"
    end
  end
end
