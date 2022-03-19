# frozen_string_literal: true

module Leftovers
  # zero dependency zeitwerk
  module Autoloader
    ALL_CAPS_NAMES = %w{ast cli version erb json yaml}.freeze

    def self.included(klass)
      ::Dir[glob_children(klass)].each_entry do |path|
        klass.autoload(class_from_path(path), path)
      end
    end

    def self.class_from_path(path)
      name = ::File.basename(path).delete_suffix('.rb')
      if ALL_CAPS_NAMES.include?(name)
        name.upcase
      else
        name.gsub(/(?:^|_)(\w)/, &:upcase).delete('_')
      end
    end

    def self.dir_path_from_class(klass)
      klass.name.gsub(/::/, '/')
        .gsub(/(?<=[a-z])([A-Z])/, '_\1').downcase
    end

    def self.glob_children(klass)
      "#{root}/#{dir_path_from_class(klass)}/*.rb"
    end

    def self.root
      ::File.dirname(__dir__)
    end
  end
end
