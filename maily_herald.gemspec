$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "maily_herald/api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "maily_herald-api"
  s.version     = MailyHerald::Api::VERSION
  s.authors     = ["Łukasz Jachymczyk"]
  s.email       = ["lukasz@sology.eu"]
  s.homepage    = "https://github.com/Sology/maily_herald-api"
  s.license     = "LGPL-3.0"
  s.description = s.summary = "Email processing solution for Ruby on Rails applications"

  s.files = Dir["{app,config,db,lib,bin}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.2.0"
  s.add_dependency "active_model_serializers", "~> 0.10.0"
  # s.add_dependency "maily_herald", "~> 1.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-shell"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "spring-commands-rspec"
  s.add_development_dependency "yard"
  s.add_development_dependency "redcarpet" # for yard markdown formatting
end
