# frozen_string_literal: true

module Leftovers
  module AST
    module HasArguments
      def positional_arguments
        @memo.fetch(:positional_arguments) do
          @memo[:positional_arguments] = begin
            if kwargs
              arguments[0...-1]
            else
              arguments
            end
          end
        end
      end

      def kwargs
        @memo.fetch(:kwargs) do
          @memo[:kwargs] = begin
            args = arguments
            next unless args

            last_arg = args[-1]
            last_arg if last_arg&.hash?
          end
        end
      end
    end
  end
end
