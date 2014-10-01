require 'spec_helper'

describe SimpleStateMachine do

  it "has an error that extends RuntimeError" do
    SimpleStateMachine::IllegalStateTransitionError.superclass.should == RuntimeError
  end

  let(:klass) do
    Class.new do
      extend SimpleStateMachine
      def initialize(state = 'state1')
        @state = state
      end
    end
  end

  describe ".event" do

    it "returns what the decorated method returns" do
      klass.instance_eval do
        event :event1,  :state1 => :state2
        define_method :event2 do
          'event2'
        end
        event :event2, :state2 => :state3
      end
      subject = klass.new
      subject.event1.should == nil
      subject.event2.should == 'event2'
    end

    it "calls existing methods" do
      klass.instance_eval do
        attr_accessor :event_called
        define_method :event do
          @event_called = true
        end
        event :event, :state1 => :state2
      end
      subject = klass.new
      subject.event
      subject.event_called.should == true
    end

    context "given an event has multiple transitions" do
      before do
        klass.instance_eval do
          event :event, :state1 => :state2, :state2 => :state3
        end
      end

      it "changes state for all transitions" do
        subject = klass.new
        subject.should be_state1
        subject.event
        subject.should be_state2
        subject.event
        subject.should be_state3
      end
    end

    context "given an event has multiple from states" do
      before do
        klass.instance_eval do
          event :event, [:state1, :state2] => :state3
        end
      end

      it "changes state for all from states" do
        subject = klass.new
        subject.event
        subject.should be_state3
        subject = klass.new 'state2'
        subject.should be_state2
        subject.event
        subject.should be_state3
      end
    end

    context "given an event has :all as from state" do
      before do
        klass.instance_eval do
          event :other_event, :state1 => :state2
          event :event, :all => :state3
        end
      end

      it "changes state from all states" do
        subject = klass.new
        subject.event
        subject.should be_state3
        subject = klass.new 'state2'
        subject.should be_state2
        subject.event
        subject.should be_state3
      end
    end

    context "given state is a symbol instead of a string" do
      before do
        klass.instance_eval do
          event :event, :state1 => :state2
        end
      end

      it "changes state" do
        subject = klass.new :state1
        subject.state.should == :state1
        subject.send(:event)
        subject.should be_state2
      end
    end

    context "given an RuntimeError begin state" do
      it "changes state to error_state when error can be caught" do
        class_with_error = Class.new(klass)
        class_with_error.instance_eval do
          define_method :raise_error do
            raise RuntimeError.new
          end
          event :raise_error, :state1 => :state2, RuntimeError => :failed
        end
        subject = class_with_error.new
        subject.should be_state1
        subject.raise_error
        subject.should be_failed
      end

      it "changes state to error_state when error superclass can be caught" do
        error_subclass   = Class.new(RuntimeError)
        class_with_error = Class.new(klass)
        class_with_error.instance_eval do
          define_method :raise_error do
            raise error_subclass.new
          end
          event :raise_error, :state1 => :state2, RuntimeError => :failed
        end
        subject = class_with_error.new
        subject.should be_state1
        subject.raise_error
        subject.should be_failed
      end
    end

    context "given an invalid state_transition is called" do
      before do
        klass.instance_eval do
          event :event,  :state1 => :state2
          event :event2, :state2 => :state3
        end
      end

      it "raises an IllegalStateTransitionError" do
        subject = klass.new
        lambda { subject.event2 }.should raise_error(
            SimpleStateMachine::IllegalStateTransitionError,
            "You cannot 'event2' when state is 'state1'")
      end
    end

  end

end

