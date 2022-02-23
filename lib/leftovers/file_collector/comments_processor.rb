# frozen-string-literal: true

module Leftovers
  class FileCollector
    module CommentsProcessor
      METHOD_NAME_RE = /[[:alpha:]_][[:alnum:]_]*\b[?!=]?/.freeze
      NON_ALNUM_METHOD_NAME_RE = Regexp.union(%w{
        []= [] ** ~ +@ -@ * / % + - >> << &
        ^ | <=> <= >= < > === == != =~ !~ !
      }.map { |op| /#{Regexp.escape(op)}/ })
      CONSTANT_NAME_RE = /[[:upper:]][[:alnum:]_]*\b/.freeze
      NAME_RE = Regexp.union(METHOD_NAME_RE, NON_ALNUM_METHOD_NAME_RE, CONSTANT_NAME_RE)
      NAME_LIST_RE = /#{NAME_RE}(?:[, :]+#{NAME_RE})*/.freeze
      LEFTOVERS_CALL_RE = /\bleftovers:call(?:s|e(?:d|rs?))? (#{NAME_LIST_RE})/.freeze
      LEFTOVERS_ALLOW_RE = /\bleftovers:(?:keeps?|skip(?:s|ped|)|allow(?:s|ed|))\b/.freeze
      LEFTOVERS_TEST_RE = /\bleftovers:(?:for_tests?|tests?|testing|test_only)\b/.freeze
      LEFTOVERS_DYNAMIC_RE = /\bleftovers:dynamic[: ](#{NAME_LIST_RE})/.freeze

      class << self
        def process(comments, collector)
          comments.each do |comment|
            process_leftovers_keep_comment(comment, collector)
            process_leftovers_test_comment(comment, collector)
            process_leftovers_dynamic_comment(comment, collector)
            process_leftovers_call_comment(comment, collector)
          end
        end

        def process_leftovers_keep_comment(comment, collector)
          return unless comment.text.match?(LEFTOVERS_ALLOW_RE)

          collector.allow_lines << comment.loc.line
        end

        def process_leftovers_test_comment(comment, collector)
          return unless comment.text.match?(LEFTOVERS_TEST_RE)

          collector.test_lines << comment.loc.line
        end

        def process_leftovers_dynamic_comment(comment, collector)
          match = comment.text.match(LEFTOVERS_DYNAMIC_RE)
          return unless match

          collector.dynamic_lines[comment.loc.line] = match[1].scan(NAME_RE)
        end

        def process_leftovers_call_comment(comment, collector)
          match = comment.text.match(LEFTOVERS_CALL_RE)
          return unless match

          match[1].scan(NAME_RE).each { |s| collector.add_call(s.to_sym) }
        end
      end
    end
  end
end
