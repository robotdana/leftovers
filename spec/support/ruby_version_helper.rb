# frozen_string_literal: true

::RSpec.configure do |c|
  c.before do |example|
    ruby_version = example.metadata[:ruby_version_at_least]
    next unless ruby_version

    if Gem::Version.new(ruby_version) > Gem::Version.new(RUBY_VERSION)
      skip "Only run this example in ruby version >= #{ruby_version}"
    end
  end
end
