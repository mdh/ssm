require 'spec_helper'

describe "Mountable" do
  before do
    mountable_class = Class.new(SimpleStateMachine::StateMachineDefinition) do
      event(:event, :state1 => :state2)

      def decorator_class
        SimpleStateMachine::Decorator::Default
      end
    end
    klass = Class.new do
      attr_accessor :event_called
      extend SimpleStateMachine::Mountable
      mount_state_machine mountable_class
      def event_without_managed_state
        @event_called = true
      end
    end
    @instance = klass.new
    @instance.state = 'state1'
  end

  it "has state_helper methods" do
    @instance.should be_state1
    @instance.should_not be_state2
  end

  it "calls existing methods" do
    @instance.event
    @instance.should be_state2
    @instance.event_called.should == true
  end
end
