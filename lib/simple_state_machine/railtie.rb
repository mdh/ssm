require 'simple_state_machine'
require 'rails'

module SimpleStateMachine
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/graphiz.rake"
    end
  end
end

