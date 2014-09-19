# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'palmade/tapsilog/version'

Gem::Specification.new do |gem|
  gem.name     = 'tapsilog'
  gem.version  = Palmade::Tapsilog::VERSION
  gem.authors  = ['Palmade']
  gem.homepage = 'http://github.com/palmade/tapsilog'
  gem.summary  = 'Hybrid app-level logger from Palmade. Analogger fork.'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'eventmachine', '~> 1.0.0'

  gem.add_development_dependency('rspec', '~> 3.0')
  gem.add_development_dependency('rake')
end
