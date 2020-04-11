# frozen_string_literal: true

module Leftovers
  module Haml
    module_function

    def precompile(file) # rubocop:disable Metrics/MethodLength
      Leftovers.try_require('haml', message: <<~MESSAGE)
        Skipped parsing a haml file, because the haml gem was not available
        `gem install Haml`
      MESSAGE
      if defined?(::Haml)
        begin
          ::Haml::Engine.new(file).precompiled
        rescue ::Haml::SyntaxError => e
          Leftovers.warn "#{e.class}: #{e.message} #{filename}:#{e.line}"
          ''
        end
      else
        ''
      end
    end
  end
end
