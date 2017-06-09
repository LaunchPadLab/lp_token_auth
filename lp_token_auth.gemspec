lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lp_token_auth/version'

Gem::Specification.new do |s|
  s.name                  = 'lp_token_auth'
  s.version               = LpTokenAuth::VERSION
  s.date                  = '2017-02-03'
  s.summary               = 'Auth!'
  s.description           = 'Simple token authentication'
  s.authors               = ['Dave Corwin']
  s.email                 = 'dave@launchpadlab.com'
  s.homepage              = 'https://github.com/launchpadlab/lp_token_auth'
  s.license               = 'MIT'
  s.required_ruby_version = '>= 2.3.0'
  s.files                 = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.add_dependency        'jwt', '>= 1.5.6'
  s.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
  s.add_development_dependency 'minitest', '~> 5.10', '>= 5.10.1'
end
