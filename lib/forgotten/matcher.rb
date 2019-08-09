module Forgotten
  class Matcher
    attr_reader :name
    attr_reader :activesupport
    attr_reader :before
    attr_reader :after
    attr_reader :suffix
    attr_reader :prefix

    def self.wrap(args)
      Array(args).map { |arg| Matcher.new(arg) }
    end

    def initialize(arg)
      if arg.is_a?(Hash)
        @name = arg[:name].to_sym
        @activesupport = Array(arg[:activesupport])
        @before = arg[:before]
        @after = arg[:after]
        @suffix = arg[:suffix]
        @prefix = arg[:prefix]
      else
        @name = arg.to_sym
      end
    end

    def to_sym
      name
    end

    def to_s
      name.to_s
    end

    def transform(string)
      string = string.to_s
      string = string.split(before, 2)[0] if before
      string = string.split(after, 2)[1] if after
      string = process_activesupport(string)
      "#{prefix}#{string}#{suffix}"
    end

    def process_activesupport(string)
      return string if !activesupport || activesupport.empty?

      Forgotten.try_require('active_support/core_ext/string', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Forgotten.try_require('active_support/inflections', "Tried transforming a rails symbol file, but the activesupport gem was not available\n`gem install activesupport`")
      Forgotten.try_require(File.join(Dir.pwd, 'config', 'initializers', 'inflections.rb'))

      activesupport.each do |method|
        string = string.send(method)
      end
      string
    end
  end
end
