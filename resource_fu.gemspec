$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "resource_fu/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "resource_fu"
  s.version     = ResourceFu::VERSION
  s.authors     = ["Droid Labs LLC"]
  s.email       = ["0@droidlabs.com"]
  s.homepage    = "http://droidlabs.pro"
  s.summary     = "ResourceFu"
  s.description = "ResourceFu"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activesupport", "~> 3.2.6"
end
