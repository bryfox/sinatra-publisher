Gem::Specification.new do |s|
  s.name        = "sinatra-publisher"
  s.version     = "0.3.0"
  s.authors     = "Bryan Fox"
  s.email       = "bryan@bryfox.com"
  s.homepage    = "http://github.com/bryfox/sinatra-publisher"
  s.summary     = "Publish an erb-based sinatra app out to static HTML files."
  s.description = "Use sinatra to build a templated site which can be published out to static HTML and hosted without infrastructure"

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md CHANGELOG.md)
  s.require_path = 'lib'

  s.add_dependency 'sinatra', '~> 1.1'
  s.add_dependency 'rack', '~> 1.1'
  s.add_dependency 'rack', '~> 1.1'
  s.add_dependency 'rack-test', "~> 0.6"
  s.add_dependency 'zipruby', "~> 0.3.6"
end