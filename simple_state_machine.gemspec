# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)  
require "simple_state_machine/version"   

Gem::Specification.new do |s|
  s.name = %q{simple_state_machine}
  s.version     = SimpleStateMachine::VERSION
  s.platform    = Gem::Platform::RUBY

  s.authors = ["Marek de Heus", "Petrik de Heus"]
  s.description = %q{A simple DSL to decorate existing methods with state transition guards.}
  s.email = ["FIX@example.com"]
  s.homepage = %q{http://github.com/mdh/ssm}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A simple DSL to decorate existing methods with logic that guards state transitions.}
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.add_development_dependency "rake"
  s.add_development_dependency "ZenTest"
  s.add_development_dependency "rspec"
  s.add_development_dependency "activerecord", "~>2.3.5"
  s.add_development_dependency "sqlite3-ruby"
  s.add_development_dependency "ruby-debug"
end

