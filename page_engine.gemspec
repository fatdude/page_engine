# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "page_engine"
  s.summary = "Insert PageEngine summary."
  s.description = "Insert PageEngine description."
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.version = "0.0.1"
  
  s.add_dependency 'simple_form'
  s.add_dependency 'RedCloth'
  s.add_dependency 'haml-rails'
  s.add_dependency 'awesome_nested_set'
  s.add_dependency 'BlueCloth'
  s.add_development_dependency 'rspec-rails'
end
