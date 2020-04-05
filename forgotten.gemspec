
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "forgotten/version"

Gem::Specification.new do |spec|
  spec.name          = "forgotten"
  spec.version       = Forgotten::VERSION
  spec.authors       = ["Dana Sherson"]
  spec.email         = ["robot@dana.sh"]

  spec.summary       = %q{Find unused methods and classes/modules}
  spec.homepage      = "http://github.com/robotdana/forgotten"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://github.com/robotdana/forgotten"
  spec.metadata["changelog_uri"] = "http://github.com/robotdana/forgotten/blob/master/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.1"
  spec.add_development_dependency "haml"
  spec.add_development_dependency "activesupport"
  spec.add_dependency "fast_ignore", "~> 0.6.0"
  spec.add_dependency "parser"
  spec.add_dependency "parallel"
end
