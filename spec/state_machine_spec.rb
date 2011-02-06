require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SimpleStateMachine::StateMachine do

  describe "#next_state" do
    before do
      klass = Class.new do
        extend SimpleStateMachine
        def initialize() @state = 'state1' end
        event :event1, :state1 => :state2
        event :event2, :state2 => :state3
      end
      @subject = klass.new.state_machine
    end

    it "returns the next state for the event and current state" do
      @subject.next_state('event1').should == 'state2'
    end

    it "returns nil if no next state for the event and current state exists" do
      @subject.next_state('event2').should be_nil
    end
  end

end

