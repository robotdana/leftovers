# frozen_string_literal: true

module Leftovers
  class Reporter
    def call(definition)
      Leftovers.puts(
        "\e[36m#{definition.full_location}\e[0m #{definition.full_name} \e[2m#{definition.highlighted_source("\e[33m", "\e[0;2m")}\e[0m" # rubocop:disable Layout/LineLength
      )
    end
  end
end
