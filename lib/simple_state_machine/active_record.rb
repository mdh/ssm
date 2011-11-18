module SimpleStateMachine::ActiveRecord

  include SimpleStateMachine::Mountable
  include SimpleStateMachine::Extendable
  include SimpleStateMachine::Inheritable

  def state_machine_definition
    unless @state_machine_definition
      @state_machine_definition = SimpleStateMachine::StateMachineDefinition.new
      @state_machine_definition.decorator_class = SimpleStateMachine::Decorator::ActiveRecord
      @state_machine_definition.subject = self
    end
    @state_machine_definition
  end
end
