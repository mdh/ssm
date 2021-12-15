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
    expect(subject).to be_state1
    subject.event1
    expect(subject).to be_state2
    subject.event1
    expect(subject).to be_state3
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
      expect(subject.ssm_state).to eq('state1')
      subject.event1
      expect(subject.ssm_state).to eq('state2')
      subject.event2
      expect(subject.ssm_state).to eq('state3')
    end

    it "works with state helper methods" do
      expect(subject).to be_state1
      subject.event1
      expect(subject).to be_state2
      subject.event2
      expect(subject).to be_state3
    end

    it "raise an error if an invalid state_transition is called" do
      expect { subject.event2 }.to raise_error(SimpleStateMachine::IllegalStateTransitionError, "You cannot 'event2' when state is 'state1'")
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
      expect(subject.state).to eq('state1')
      subject.event1
      expect(subject.state).to eq('failed')
    end
  end

  describe "#transitions" do
    it "has a list of transitions" do
      expect(smd.transitions).to be_a(Array)
      expect(smd.transitions.first).to be_a(SimpleStateMachine::Transition)
    end
  end

  describe "#to_s" do
    it "converts to readable string format" do
      expect(smd.to_s).to match(Regexp.new("state1.event1! => state2"))
    end
  end

end

