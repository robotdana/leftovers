# frozen_string_literal: true

require 'tmpdir'
require 'pathname'

module TempFileHelper
  def with_temp_dir
    @__temp_dir = Pathname.new(Dir.mktmpdir + '/')
    allow(Leftovers).to receive_messages(pwd: @__temp_dir)
  end

  def temp_file(filename, body = '')
    path = @__temp_dir.join(filename)
    path.parent.mkpath
    path.write(body)
    path
  end

  def temp_dir
    @__temp_dir
  end
end

RSpec.configure do |config|
  config.include TempFileHelper
  config.after do
    @__temp_dir&.rmtree
  end
end
