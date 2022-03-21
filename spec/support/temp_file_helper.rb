# frozen_string_literal: true

require 'tmpdir'
require 'pathname'

module TempFileHelper
  def temp_file(filename, body = '')
    raise 'Add :with_temp_dir to the metadata' unless @__temp_dir

    path = @__temp_dir.join(filename)
    path.parent.mkpath
    path.write(body)
    path
  end

  def temp_dir
    @__temp_dir
  end
end

::RSpec.configure do |config|
  config.include TempFileHelper

  config.before(:each, :with_temp_dir) do
    @__temp_dir = ::Pathname.new(::Dir.mktmpdir + '/')
    ::Leftovers::Config.reset # MatcherBuilders::Path calls Leftovers.pwd, make it forget
    ::Leftovers.reset
    allow(::Leftovers).to receive_messages(pwd: @__temp_dir)
  end

  config.after(:each, :with_temp_dir) do
    @__temp_dir.rmtree
    ::Leftovers::Config.reset # MatcherBuilders::Path calls Leftovers.pwd, make it forget
    ::Leftovers.reset
  end
end
