lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "view_component_attributes/version"

Gem::Specification.new do |spec|
  spec.name = "view_component_attributes"
  spec.version = ViewComponentAttributes::VERSION
  spec.authors = ["Romaric Pascal", "Amba Health & Care"]
  spec.email = ["hello@romaricpascal.is", "developers@amba.co"]

  spec.summary = "Concerns to help manage attributes in View Components"
  spec.homepage = "https://github.com/Amba-Health/view_component_attributes"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", ">= 12.2"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rails", ">= 6.1.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "standardrb"

  spec.add_dependency "zeitwerk"
  spec.add_dependency "view_component"
  spec.add_dependency "activemodel"
end
