require_relative "./forgotten/version"
require_relative "./forgotten/collector"
require_relative "./forgotten/file_list"
require_relative "./forgotten/config"
require_relative "./forgotten/haml"

module Forgotten
  class Error < StandardError; end

  module_function

  def config
    @config ||= Forgotten::Config.new
  end
end
