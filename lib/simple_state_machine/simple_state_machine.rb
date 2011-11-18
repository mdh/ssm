module SimpleStateMachine

  ##
  # Allows class to mount a state_machine
  module Mountable
    def state_machine_definition
      unless @state_machine_definition
        @state_machine_definition = StateMachineDefinition.new
        @state_machine_definition.subject = self
      end
      @state_machine_definition
    end

    def state_machine_definition= state_machine_definition
      @state_machine_definition = state_machine_definition
      state_machine_definition.transitions.each do |transition|
        state_machine_definition.decorator.decorate(transition)
      end
    end

    def mount_state_machine mountable_class
      self.state_machine_definition = mountable_class.new
      self.state_machine_definition.subject = self
      self.state_machine_definition.add_events
    end
  end
  include Mountable

  ##
  # Adds state machine methods to the extended class
  module Extendable
    # mark the method as an event and specify how the state should transition
    def event event_name, state_transitions
      state_machine_definition.define_event event_name, state_transitions
    end
  end
  include Extendable

  ##
  # Allows subclasses to inherit state machines
  module Inheritable
    def inherited(subclass)
      subclass.state_machine_definition = state_machine_definition.clone
      decorator = state_machine_definition.decorator
      decorator.subject = subclass
      subclass.state_machine_definition.decorator = decorator
      super
    end
  end
  include Inheritable

end
