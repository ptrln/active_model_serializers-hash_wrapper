# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_model_serializers/hash_wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = "active_model_serializers-hash_wrapper"
  spec.version       = ActiveModelSerializers::HashWrapper::VERSION
  spec.authors       = ["Peter Lin"]
  spec.email         = ["peter@ptrln.com"]

  spec.summary       = %q{Serialize hashes with ActiveModelSerializers.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "active_model_serializers"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "minitest"
end
