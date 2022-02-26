# frozen_string_literal: true

require 'haml'

module Leftovers
  module Precompilers
    module Haml
      def self.precompile(haml)
        ::Haml::Engine.new(haml).precompiled
      rescue ::Haml::SyntaxError => e
        raise Leftovers::PrecompileError.new(e.message, line: e.line)
      end
    end
  end
end
