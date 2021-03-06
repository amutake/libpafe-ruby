lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pasori/version'

Gem::Specification.new do |spec|
  spec.name          = "libpafe"
  spec.version       = Pasori::VERSION
  spec.authors       = ["Hiroyuki Ito"]
  spec.email         = ["ZXB01226 at nifty.ne.jp"]

  spec.summary       = "Ruby bindings for the libpafe"
  spec.description   = "Ruby bindings for the libpafe"
  spec.homepage      = "https://github.com/htrb/libpafe-ruby"
  spec.license       = "GPLv2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)\
  /}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/pasori/extconf.rb"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler"
end
