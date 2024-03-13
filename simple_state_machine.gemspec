# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_state_machine/version"

Gem::Specification.new do |s|
  s.name             = %q{simple_state_machine}
  s.version          = SimpleStateMachine::VERSION
  s.platform         = Gem::Platform::RUBY
  s.authors          = ["Marek de Heus", "Petrik de Heus"]
  s.description      = %q{A simple DSL to decorate existing methods with state transition guards.}
  s.email            = ["FIX@example.com"]
  s.homepage         = %q{http://github.com/mdh/ssm}
  s.extra_rdoc_files = ["LICENSE","README.rdoc"]
  s.files            = Dir.glob("lib/**/*") + %w[Changelog.rdoc LICENSE README.rdoc]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_paths    = ["lib"]
  s.summary          = %q{A simple DSL to decorate existing methods with logic that guards state transitions.}
end

