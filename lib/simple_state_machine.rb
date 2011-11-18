require 'simple_state_machine/simple_state_machine'
require 'simple_state_machine/state_machine'
require 'simple_state_machine/tools/graphviz'
require 'simple_state_machine/tools/inspector'
require 'simple_state_machine/state_machine_definition'
require 'simple_state_machine/transition'
require 'simple_state_machine/decorator/default'
if defined?(ActiveRecord)
  require 'simple_state_machine/active_record'
  require 'simple_state_machine/decorator/active_record'
end
require "simple_state_machine/railtie" if defined?(Rails::Railtie)

