lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plotrb/version'

Gem::Specification.new do |spec|
  spec.name          = 'plotrb'
  spec.version       = Plotrb::VERSION
  spec.authors       = ['Zuhao Wan']
  spec.email         = 'wanzuhao@gmail.com'
  spec.description   = %q{Plotrb is a plotting tool in Ruby.}
  spec.summary       = %q{Plotrb is a plotting tool in Ruby, built on D3.}
  spec.homepage      = 'https://github.com/zuhao/plotrb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'
  spec.add_dependency 'yajl-ruby'
  spec.add_dependency 'hashie'
end
