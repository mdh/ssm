require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SimpleStateMachine::Decorator do

  describe "#initialize" do
    before do
      klass = Class.new do
        # TODO the need for defining this method
        def self.state_machine_definition
          @state_machine_definition ||= SimpleStateMachine::StateMachineDefinition.new
        end
      end        
      SimpleStateMachine::Decorator.new klass
      @instance = klass.new
    end

    it "defines a state_machine method" do
      @instance.state_machine.should be_an(SimpleStateMachine::StateMachine)
    end

    it "defines a state getter method" do
      @instance.should respond_to(:state)
    end

    it "defines a state setter method" do
      @instance.should respond_to(:state=)
    end
  end

  describe "#decorate" do
    context "given a class" do
      before do
        klass = Class.new do
          # TODO the need for defining this method
          def self.state_machine_definition
            @state_machine_definition ||= SimpleStateMachine::StateMachineDefinition.new
          end
        end
        decorator = SimpleStateMachine::Decorator.new klass
        decorator.decorate SimpleStateMachine::Transition.new(:event, :state1, :state2)
        @instance = klass.new
        @instance.state = 'state1'
      end

      it "defines state_helper_methods for both states" do
        @instance.state1?.should  == true
        @instance.state2?.should  == false
      end
      
      it "defines an event method" do
        @instance.should respond_to(:event)
      end
    end

    context "given a class with predefined methods" do
      before do
        klass = Class.new do
          # TODO the need for defining this method
          def self.state_machine_definition
            @state_machine_definition ||= SimpleStateMachine::StateMachineDefinition.new
          end
          # predefined methods
          def state1?() "state1" end
          def state2?() "state2" end
          def event() "predefined method" end
        end
        transition =  SimpleStateMachine::Transition.new(:event, :state1, :state2)
        decorator = SimpleStateMachine::Decorator.new klass
        decorator.decorate transition
        klass.state_machine_definition.transitions << transition
        @instance = klass.new
        @instance.state = 'state1'
      end

      it "does not overwrite predefined state_helper_methods" do
        @instance.state1?.should  == "state1"
        @instance.state2?.should  == "state2"
      end

      it "does not overwrite predefined event method" do
        @instance.event.should == "predefined method"
      end
    end
    
  end

end
