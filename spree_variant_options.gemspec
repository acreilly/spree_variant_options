Gem::Specification.new do |s|
  s.name        = 'spree_variant_options'
  s.version     = '1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Spencer Steffen"]
  s.email       = ["spencer@citrusme.com"]
  s.homepage    = "https://github.com/citrus/spree_variant_options"
  s.summary     = %q{Spree Variant Options is a simple spree extension that replaces the radio-button variant selection with groups of option types and values.}
  s.description = %q{Spree Variant Options is a simple spree extension that replaces the radio-button variant selection with groups of option types and values. Please see the documentation for more details.}
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_path = 'lib'
  s.requirements << 'none'

  # Runtime
  s.add_dependency 'spree_core', '~> 2.2.0'

  # Development
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-script'
  s.add_development_dependency 'therubyracer'
  s.add_development_dependency 'database_cleaner'

end
