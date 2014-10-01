require 'spec_helper'

describe SimpleStateMachine::StateMachineDefinition do

  let(:klass) do
    Class.new do
      extend SimpleStateMachine
      def initialize(state = 'state1')
        @state = state
      end
      event :event1, :state1 => :state2, :state2 => :state3
    end
  end
  let(:smd) { klass.state_machine_definition }

  it "is inherited by subclasses" do
    subject = Class.new(klass).new
    subject.should be_state1
    subject.event1
    subject.should be_state2
    subject.event1
    subject.should be_state3
  end

  describe '#state_method' do
    subject do
      klass = Class.new do
        attr_reader :ssm_state
        extend SimpleStateMachine
        state_machine_definition.state_method = :ssm_state

        def initialize(state = 'state1')
          @ssm_state = state
        end
        event :event1, :state1 => :state2
        event :event2, :state2 => :state3
      end
      klass.new
    end

    it "is used when changing state" do
      subject.ssm_state.should == 'state1'
      subject.event1
      subject.ssm_state.should == 'state2'
      subject.event2
      subject.ssm_state.should == 'state3'
    end

    it "works with state helper methods" do
      subject.should be_state1
      subject.event1
      subject.should be_state2
      subject.event2
      subject.should be_state3
    end

    it "raise an error if an invalid state_transition is called" do
      lambda { subject.event2 }.should raise_error(SimpleStateMachine::IllegalStateTransitionError, "You cannot 'event2' when state is 'state1'")
    end

  end

  describe '#default_error_state' do
    subject do
      klass = Class.new do
        attr_reader :state
        extend SimpleStateMachine
        state_machine_definition.default_error_state = :failed

        def initialize(state = 'state1')
          @state = state
        end

        def event1
          raise "Some error during event"
        end
        event :event1, :state1 => :state2
      end
      klass.new
    end

    it "is set when an error occurs during an event" do
      subject.state.should == 'state1'
      subject.event1
      subject.state.should == 'failed'
    end
  end

  describe "#transitions" do
    it "has a list of transitions" do
      smd.transitions.should be_a(Array)
      smd.transitions.first.should be_a(SimpleStateMachine::Transition)
    end
  end

  describe "#to_s" do
    it "converts to readable string format" do
      smd.to_s.should =~ Regexp.new("state1.event1! => state2")
    end
  end

end

