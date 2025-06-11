require_relative "lib/active_registration/version"

Gem::Specification.new do |spec|
  spec.name        = "active_registration"
  spec.version     = ActiveRegistration::VERSION
  spec.authors     = [ "Salanoid" ]
  spec.email       = [ "salanoid@gmail.com" ]
  spec.homepage    = "https://rubygems.org/gems/active_registration"
  spec.summary     = "A simple gem that adds generators for sign up Rails Authentication Generator."
  spec.description = "A drop-in Rails engine that adds secure user registration with email confirmation to your rails 8+ application, that uses Rails Authentication Generator."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Salanoid/active_registration"
  spec.metadata["changelog_uri"] = "https://github.com/Salanoid/active_registration/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"
end
