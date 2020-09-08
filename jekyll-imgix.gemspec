# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/imgix/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-imgix"
  spec.version       = Jekyll::Imgix::VERSION
  spec.authors       = ["kellysutton"]
  spec.email         = ["kelly@imgix.com"]

  spec.summary       = %q{A simple Ruby gem to bring imgix to your Jekyll site.}
  spec.homepage      = "https://github.com/imgix/jekyll-imgix"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "imgix", "~> 1.1.0"

  spec.add_development_dependency "liquid", "~> 3.0"
  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec"
end
