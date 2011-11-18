require 'spec_helper'

describe SimpleStateMachine::Tools::Inspector do

  describe "#begin_states" do
    before do
      @klass = Class.new(SimpleStateMachine::StateMachineDefinition) do
        def add_events
          define_event(:event_a, :state1      => :state2)
          define_event(:event_b, :state2      => :state3)
          define_event(:event_c, :state1      => :state3)
          define_event(:event_c, RuntimeError => :state3)
        end

        def decorator_class
          SimpleStateMachine::Decorator::Default
        end
      end
    end

    it "returns all 'from' states that aren't 'to' states" do
      @klass.new.begin_states.should == [:state1, RuntimeError]
    end
  end

  describe "#end_states" do
    before do
      @klass = Class.new(SimpleStateMachine::StateMachineDefinition) do
        def add_events
          define_event(:event_a, :state1 => :state2)
          define_event(:event_b, :state2 => :state3)
          define_event(:event_c, :state1 => :state3)
        end

        def decorator_class
          SimpleStateMachine::Decorator::Default
        end

      end
    end

    it "returns all 'to' states that aren't 'from' states" do
      @klass.new.end_states.should == [:state3]
    end
  end

  describe "#states" do
    before do
      @klass = Class.new(SimpleStateMachine::StateMachineDefinition) do
        def add_events
          define_event(:event_a, :state1 => :state2)
          define_event(:event_b, :state2 => :state3)
          define_event(:event_c, :state1 => :state3)
        end

        def decorator_class
          SimpleStateMachine::Decorator::Default
        end

      end
    end

    it "returns all states" do
      @klass.new.states.map(&:to_s).sort.should == %w{state1 state2 state3}
    end
  end

end


