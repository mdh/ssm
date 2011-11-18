require 'spec_helper'

describe SimpleStateMachine do

  it "has an error that extends RuntimeError" do
    SimpleStateMachine::IllegalStateTransitionError.superclass.should == RuntimeError
  end

  describe ".event" do

    before do
      @klass = Class.new do
        extend SimpleStateMachine
        def initialize(state = 'state1')
          @state = state
        end
      end
    end

    it "returns what the decorated method returns" do
      klass = Class.new(@klass)
      klass.instance_eval do
        event :event1,  :state1 => :state2
        define_method :event2 do
          'event2'
        end
        event :event2, :state2 => :state3
      end
      example = klass.new
      example.event1.should == nil
      example.event2.should == 'event2'
    end

    it "calls existing methods" do
      klass = Class.new(@klass)
      klass.instance_eval do
        attr_accessor :event_called
        define_method :event do
          @event_called = true
        end
        event :event, :state1 => :state2
      end
      example = klass.new
      example.event
      example.event_called.should == true
    end

    context "given an event has multiple transitions" do
      it "changes state for all transitions" do
        klass = Class.new(@klass)
        klass.instance_eval do
          event :event, :state1 => :state2, :state2 => :state3
        end
        example = klass.new
        example.should be_state1
        example.event
        example.should be_state2
        example.event
        example.should be_state3
      end
    end

    context "given an event has multiple from states" do
      it "changes state for all from states" do
        klass = Class.new(@klass)
        klass.instance_eval do
          event :event, [:state1, :state2] => :state3
        end
        example = klass.new
        example.event
        example.should be_state3
        example = klass.new 'state2'
        example.should be_state2
        example.event
        example.should be_state3
      end
    end

    context "given an event has :all as from state" do
      it "changes state from all states" do
        klass = Class.new(@klass)
        klass.instance_eval do
          event :other_event, :state1 => :state2
          event :event, :all => :state3
        end
        example = klass.new
        example.event
        example.should be_state3
        example = klass.new 'state2'
        example.should be_state2
        example.event
        example.should be_state3
      end
    end

    context "given state is a symbol instead of a string" do
      it "changes state" do
        klass = Class.new(@klass)
        klass.instance_eval do
          event :event, :state1 => :state2
        end
        example = klass.new :state1
        example.state.should == :state1
        example.send(:event)
        example.should be_state2
      end
    end

    context "given an RuntimeError begin state" do
      it "changes state to error_state when error can be caught" do
        class_with_error = Class.new(@klass)
        class_with_error.instance_eval do
          define_method :raise_error do
            raise RuntimeError.new
          end
          event :raise_error, :state1 => :state2, RuntimeError => :failed
        end
        example = class_with_error.new
        example.should be_state1
        example.raise_error
        example.should be_failed
      end

      it "changes state to error_state when error superclass can be caught" do
        error_subclass   = Class.new(RuntimeError)
        class_with_error = Class.new(@klass)
        class_with_error.instance_eval do
          define_method :raise_error do
            raise error_subclass.new
          end
          event :raise_error, :state1 => :state2, RuntimeError => :failed
        end
        example = class_with_error.new
        example.should be_state1
        example.raise_error
        example.should be_failed
      end
    end

    context "given an invalid state_transition is called" do
      it "raises an IllegalStateTransitionError" do
        klass = Class.new(@klass)
        klass.instance_eval do
          event :event,  :state1 => :state2
          event :event2, :state2 => :state3
        end
        example = klass.new
        lambda { example.event2 }.should raise_error(
            SimpleStateMachine::IllegalStateTransitionError,
            "You cannot 'event2' when state is 'state1'")
      end
    end

  end

end

