$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "page_engine/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.

Gem::Specification.new do |s|
  s.name = "page_engine"
  s.author = "Mark Asson"
  s.email = "mark@fatdude.net"
  s.homepage = "https://github.com/fatdude/page_engine"
  s.summary = "Extends a rails application with pages"
  s.description = "Extends a rails application with pages, allowing the generation of navigation, breadcrumbs etc. Content can be currently written in markdown, textile or plain html."
  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["spec/**/*"]
  s.version = PageEngine::VERSION
  
  s.add_dependency 'simple_form'
  s.add_dependency 'RedCloth'
  s.add_dependency 'haml-rails'
  s.add_dependency 'awesome_nested_set'
  s.add_dependency 'BlueCloth'
  s.add_development_dependency 'rspec-rails'
end
