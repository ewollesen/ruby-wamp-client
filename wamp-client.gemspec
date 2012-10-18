# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wamp/client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric Wollesen"]
  gem.email         = ["ericw@xmtp.net"]
  gem.description   = %q{WAMP client}
  gem.summary       = %q{WAMP client}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wamp-client"
  gem.require_paths = ["lib"]
  gem.version       = WAMP::Client::VERSION

  gem.add_development_dependency("rake")
  gem.add_development_dependency("pry")
  gem.add_development_dependency("debugger")

  gem.add_dependency("json")
  gem.add_dependency("net-ws", "~> 0.0.2")
end
