require 'spec_helper'

describe SimpleStateMachine::Mountable do
  class MountableExample < SimpleStateMachine::StateMachineDefinition
    event(:event, :state1 => :state2)

    def decorator_class
      SimpleStateMachine::Decorator::Default
    end
  end

  let(:klass) do
    Class.new do
      attr_accessor :event_called
      extend SimpleStateMachine::Mountable
      mount_state_machine MountableExample
      def event_without_managed_state
        @event_called = true
      end
    end
  end
  subject do
    klass.new.tap{|i| i.state = 'state1' }
  end

  it "has state_helper methods" do
    expect(subject).to be_state1
    expect(subject).not_to be_state2
  end

  it "calls existing methods" do
    subject.event
    expect(subject).to be_state2
    expect(subject.event_called).to eq(true)
  end
end
