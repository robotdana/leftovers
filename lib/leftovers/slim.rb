# frozen_string_literal: true

module Leftovers
  module Slim
    module_function

    def precompile(file, name)
      return '' unless Leftovers.try_require('slim', message: <<~MESSAGE) # rubocop:disable Layout/EmptyLineAfterGuardClause
        Skipped parsing #{name.relative_path}, because the slim gem was not available
        `gem install slim`
      MESSAGE

      begin
        ::Slim::Engine.new(file: file).call(file)
      rescue ::Slim::Parser::SyntaxError => e
        Leftovers.warn "#{e.class}: #{e.message} #{name.relative_path}:#{e.line}"
        ''
      end
    end
  end
end
