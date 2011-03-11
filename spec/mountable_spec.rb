require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mountable" do
  before do
    mountable_class = Class.new(SimpleStateMachine::StateMachineDefinition) do
      def add_events
        define_event(:event, :state1 => :state2)
      end

      def decorator_class
        SimpleStateMachine::Decorator
      end
    end
    klass = Class.new do
      extend SimpleStateMachine::Mountable
      mount_state_machine mountable_class
    end
    @instance = klass.new
    @instance.state = 'state1'
  end

  it "has state_helper methods" do
    @instance.should be_state1
    @instance.should_not be_state2
  end

end
