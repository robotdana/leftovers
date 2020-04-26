# frozen_string_literal: true

module Leftovers
  module Haml
    module_function

    def precompile(file, name) # rubocop:disable Metrics/MethodLength
      return '' unless Leftovers.try_require('haml', message: <<~MESSAGE) # rubocop:disable Layout/EmptyLineAfterGuardClause
        Skipped parsing #{name.relative_path}, because the haml gem was not available
        `gem install haml`
      MESSAGE

      begin
        ::Haml::Engine.new(file).precompiled
      rescue ::Haml::SyntaxError => e
        Leftovers.warn "#{e.class}: #{e.message} #{name.relative_path}:#{e.line}"
        ''
      end
    end
  end
end
