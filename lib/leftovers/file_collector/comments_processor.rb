# frozen_string_literal: true

module Leftovers
  class FileCollector
    module CommentsProcessor
      class << self
        def process(comments, collector)
          comments.each do |comment|
            process_leftovers_keep_comment(comment, collector)
            process_leftovers_test_comment(comment, collector)
            process_leftovers_dynamic_comment(comment, collector)
            process_leftovers_call_comment(comment, collector)
          end
        end

        private

        method_name_re = /[[:alpha:]_][[:alnum:]_]*\b[?!=]?/.freeze
        non_alnum_method_name_re = ::Regexp.union(%w{
          []= [] ** ~ +@ -@ * / % + - >> << &
          ^ | <=> <= >= < > === == != =~ !~ !
        }.map { |op| /#{::Regexp.escape(op)}/ })
        constant_name_re = /[[:upper:]][[:alnum:]_]*\b/.freeze
        NAME_RE = ::Regexp.union(method_name_re, non_alnum_method_name_re, constant_name_re)
        name_list_re = /#{NAME_RE}(?:[, :]+#{NAME_RE})*/o.freeze

        CALL_RE = /\bleftovers:call(?:s|e(?:d|rs?))? (#{name_list_re})/.freeze
        ALLOW_RE = /\bleftovers:(?:keeps?|skip(?:s|ped|)|allow(?:s|ed|))\b/.freeze
        TEST_ONLY_RE = /\bleftovers:(?:for_tests?|tests?|testing|test_only)\b/.freeze
        DYNAMIC_RE = /\bleftovers:dynamic[: ](#{name_list_re})/.freeze

        private_constant :NAME_RE, :CALL_RE, :ALLOW_RE, :TEST_ONLY_RE, :DYNAMIC_RE

        def process_leftovers_keep_comment(comment, collector)
          return unless comment.text.match?(ALLOW_RE)

          collector.allow_lines << comment.loc.line
        end

        def process_leftovers_test_comment(comment, collector)
          return unless comment.text.match?(TEST_ONLY_RE)

          collector.test_lines << comment.loc.line
        end

        def process_leftovers_dynamic_comment(comment, collector)
          match = comment.text.match(DYNAMIC_RE)
          return unless match

          collector.dynamic_lines[comment.loc.line] = match[1].scan(NAME_RE)
        end

        def process_leftovers_call_comment(comment, collector)
          match = comment.text.match(CALL_RE)
          return unless match

          match[1].scan(NAME_RE).each { |s| collector.calls << s.to_sym }
        end
      end
    end
  end
end
