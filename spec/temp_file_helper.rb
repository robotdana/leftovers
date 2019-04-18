# frozen_string_literal: true
require 'tmpdir'

module TempFileHelper
  def with_temp_dir(&block)
    dir = Pathname.new(Dir.mktmpdir)
    Dir.chdir(dir, &block)
  ensure
    dir.rmtree
  end

  def temp_files(filenames)
    filenames.each do |filename|
      temp_file(filename)
    end
  end

  def temp_file(filename, body = '')
    path = Pathname.pwd.join(filename)
    path.parent.mkpath
    path.write(body)
    path
  end
end

RSpec.configure do |config|
  config.include TempFileHelper
end
