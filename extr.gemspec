$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "extr/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "extr"
  s.version     = Extr::VERSION
  s.authors     = ["Stephan Keller"]
  s.email       = ["MiStK@gmx.de"]
  s.homepage    = ""
  s.summary     = "Extr is a Ext Direct Implementation for Rails 3.1"
  s.description = "Extr is a Rails 3.1 Ext Direct Router implemented as Rack Middleware with View Helpers and some adjustment abilities."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.0"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end

