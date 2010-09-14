# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{simple_state_machine}
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marek de Heus", "Petrik de Heus"]
  s.date = %q{2010-09-14}
  s.description = %q{A simple DSL to decorate existing methods with logic that guards state transitions.}
  s.email = ["FIX@example.com"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "examples/conversation.rb",
     "examples/lamp.rb",
     "examples/relationship.rb",
     "examples/traffic_light.rb",
     "examples/user.rb",
     "lib/simple_state_machine.rb",
     "lib/simple_state_machine/active_record.rb",
     "lib/simple_state_machine/simple_state_machine.rb",
     "simple_state_machine.gemspec",
     "spec/active_record_spec.rb",
     "spec/decorator_spec.rb",
     "spec/examples_spec.rb",
     "spec/simple_state_machine_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/mdh/ssm}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A statemachine that focuses on events instead of states}
  s.test_files = [
    "spec/active_record_spec.rb",
     "spec/decorator_spec.rb",
     "spec/examples_spec.rb",
     "spec/simple_state_machine_spec.rb",
     "spec/spec_helper.rb",
     "examples/conversation.rb",
     "examples/lamp.rb",
     "examples/relationship.rb",
     "examples/traffic_light.rb",
     "examples/user.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

