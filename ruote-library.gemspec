# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Hartog C. de Mik"]
  gem.email         = ["hartog@organisedminds.com"]
  gem.description   = %q{A library for Ruote processes, based on FS storage and sub-processes}
  gem.summary       = %q{Ruote process library}
  gem.homepage      = "https://github.com/coffeeaddict/ruote-library"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "ruote-library"
  gem.require_paths = ["lib"]
  gem.version       = "1.0.0"

  gem.add_dependency 'ruote', ['~> 2.3']

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'mocha'
end
