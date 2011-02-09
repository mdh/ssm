require 'simple_state_machine'

module SimpleStateMachine
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/graphiz.rake"
      end
    end
  end
end

