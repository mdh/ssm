require 'spec_helper'

describe SimpleStateMachine::Decorator::Default do

  context "given a class" do
    before do
      klass = Class.new do
        # TODO remove the need for defining this method
        def self.state_machine_definition
          @state_machine_definition ||= SimpleStateMachine::StateMachineDefinition.new
        end
      end
      decorator = described_class.new klass
      decorator.decorate SimpleStateMachine::Transition.new(:event, :state1, :state2)
      @instance = klass.new
      @instance.state = 'state1'
    end

    describe "#initialize" do
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
      it "defines state_helper_methods for both states" do
        @instance.state1?.should  == true
        @instance.state2?.should  == false
      end

      it "defines an event method" do
        @instance.should respond_to(:event)
      end
    end
  end

  context "given a class with predefined public methods" do
    before do
      klass = Class.new do
        # TODO remove the need for defining this method
        def self.state_machine_definition
          @state_machine_definition ||= SimpleStateMachine::StateMachineDefinition.new
        end
        # predefined methods
        def state1?() "state1"            end
        def state2?() "state2"            end
        def event()   "predefined method" end
      end
      transition =  SimpleStateMachine::Transition.new(:event, :state1, :state2)
      decorator = described_class.new klass
      decorator.decorate transition
      klass.state_machine_definition.transitions << transition
      @instance = klass.new
      @instance.state = 'state1'
    end

    describe "#initialize" do
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
      it "does not overwrite predefined state_helper_methods" do
        @instance.state1?.should  == "state1"
        @instance.state2?.should  == "state2"
      end

      it "does not overwrite predefined event method" do
        @instance.event.should == "predefined method"
      end
    end
  end

  context "given a class with predefined protected methods" do
    before do
      klass = Class.new do
        # TODO remove the need for defining this method
        def self.state_machine_definition
          @state_machine_definition ||= SimpleStateMachine::StateMachineDefinition.new
        end
        # predefined methods
        protected
        def state1?() "state1"            end
        def state2?() "state2"            end
        def event()   "predefined method" end
      end
      transition =  SimpleStateMachine::Transition.new(:event, :state1, :state2)
      decorator = described_class.new klass
      decorator.decorate transition
      klass.state_machine_definition.transitions << transition
      @instance = klass.new
      @instance.state = 'state1'
    end

    describe "#initialize" do
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
      it "does not overwrite predefined protected state_helper_methods" do
        @instance.send(:state1?).should  == "state1"
        @instance.send(:state2?).should  == "state2"
      end

      it "keeps predefined protected state_helper_methods protected" do
        expect { @instance.state1? }.to raise_error(NoMethodError)
        expect { @instance.state2? }.to raise_error(NoMethodError)
      end

      it "does not overwrite predefined protected event method" do
        @instance.event.should == "predefined method"
      end
    end
  end

  context "given a class with predefined private methods" do
    before do
      klass = Class.new do
        # TODO the need for defining this method
        def self.state_machine_definition
          @state_machine_definition ||= SimpleStateMachine::StateMachineDefinition.new
        end
        # predefined methods
        private
        def state1?() "state1"            end
        def state2?() "state2"            end
        def event()   "predefined method" end
      end
      transition =  SimpleStateMachine::Transition.new(:event, :state1, :state2)
      decorator = described_class.new klass
      decorator.decorate transition
      klass.state_machine_definition.transitions << transition
      @instance = klass.new
      @instance.state = 'state1'
    end

    describe "#initialize" do
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
      it "does not overwrite predefined private state_helper_methods" do
        @instance.send(:state1?).should  == "state1"
        @instance.send(:state2?).should  == "state2"
      end

      it "keeps predefined private state_helper_methods private" do
        expect { @instance.state1? }.to raise_error(NoMethodError)
        expect { @instance.state2? }.to raise_error(NoMethodError)
      end

      it "does not overwrite predefined protected event method" do
        @instance.event.should == "predefined method"
      end
    end
  end

end
