# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "metricsd/version"

Gem::Specification.new do |s|
  s.name        = "metricsd"
  s.version     = Metricsd::VERSION
  s.authors     = ["Dmytro Shteflyuk"]
  s.email       = ["kpumuk@kpumuk.info"]
  s.homepage    = "https://github.com/kpumuk/metricsd-ruby"
  s.summary     = %q{Client library for MetricsD server}
  s.description = %q{}

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'growl'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
