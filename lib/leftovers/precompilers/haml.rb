# frozen_string_literal: true

require 'haml'

module Leftovers
  module Precompilers
    module Haml
      HAML_RUNTIME_ERROR_RE = %r{
        \A
        _buf\s=\s'' # preamble
        [\s;]*
        # https://github.com/haml/haml/blob/main/lib/haml/compiler.rb#L93
        raise\s(?:::)?(?<class>.*)\.new\(%q\[(?<message>.*)\],\s(?<line>\d)+\)
        [\s;]*
        _buf # postamble
        \z
      }x.freeze

      def self.precompile(haml)
        out = ::Haml::TempleEngine.new.compile(haml)

        if (e = out.match(HAML_RUNTIME_ERROR_RE))
          raise PrecompileError.new(e[:message], line: e[:line], display_class: e[:class])
        end

        out
        # :nocov:
        # this is for haml < 6
      rescue ::Haml::Error => e
        raise PrecompileError.new(e.message, line: e.line)
        # :nocov:
      end
    end
  end
end
