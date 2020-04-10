
module Leftovers
  module Haml
    module_function
    def precompile(file)
      Leftovers.try_require('haml', "Skipped parsing a haml file, because the haml gem was not available\n`gem install haml`")
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
