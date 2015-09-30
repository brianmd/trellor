# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trellor/version'

Gem::Specification.new do |spec|
  spec.name          = 'trellor'
  spec.version       = Trellor::VERSION
  spec.authors       = ['Brian Murphy-Dye']
  spec.email         = ['brian@murphydye.com']

  spec.summary       = %q{Gem to read and write to Trello, plus a terminal interface.}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = ['trellor']
  spec.require_paths = ["lib"]

  spec.add_dependency 'ruby-trello'
  spec.add_dependency 'trollop'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
