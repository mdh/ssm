require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SimpleStateMachine::StateMachine do

  describe "#next_state" do
    subject do
      klass = Class.new do
        extend SimpleStateMachine
        def initialize() @state = 'state1' end
        event :event1, :state1 => :state2
        event :event2, :state2 => :state3
      end
      klass.new.state_machine
    end

    it "returns the next state for the event and current state" do
      subject.next_state('event1').should == 'state2'
    end

    it "returns nil if no next state for the event and current state exists" do
      subject.next_state('event2').should be_nil
    end
  end

  describe "#raised_error" do
    context "given an error can be caught" do
      let(:class_with_error) do
        Class.new do
          extend SimpleStateMachine
          def initialize(state = 'state1'); @state = state; end
          def raise_error
            raise "Something went wrong"
          end
          event :raise_error, :state1 => :state2,
                RuntimeError => :failed
          event :retry,  :failed => :success
        end
      end

      subject do
        class_with_error.new.tap{|i| i.raise_error }
      end

      it "the raised error is accessible" do
        raised_error = subject.state_machine.raised_error
        raised_error.should be_a(RuntimeError)
        raised_error.message.should == "Something went wrong"
      end

      it "the raised error is set to nil on the next transition" do
        subject.state_machine.raised_error.should be
        subject.retry
        subject.state_machine.raised_error.should_not be
      end

    end
  end

end

