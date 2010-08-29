require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class SimpleExample
  extend SimpleStateMachine
  attr_reader :event2_called
  def initialize(state = 'state1')
    @state = state
  end
  event :event1, :state1 => :state2, :state2 => :state3
  def event2
    @event2_called = true
    'event2'
  end
  event :event2, :state2 => :state3
end

describe SimpleStateMachine do
  
  it "has a default state" do
    SimpleExample.new.state.should == 'state1'
  end

  describe "events" do

    it "changes state" do
      example = SimpleExample.new
      example.should be_state1
      example.event1
      example.should be_state2
      example.event1
      example.should be_state3
    end

    it "changes state when state is a symbol instead of a string" do
      example = SimpleExample.new :state1
      example.state.should == :state1
      example.send(:event1)
      example.should be_state2
    end

    it "raise an error if an invalid state_transition is called" do
      example = SimpleExample.new
      lambda { example.event2 }.should raise_error(RuntimeError, "You cannot 'event2' when state is 'state1'")
    end

    it "return nil" do
      example = SimpleExample.new
      example.event1.should == nil
      example.event2.should == 'event2'
    end

    it "calls existing methods" do
      example = SimpleExample.new
      example.event1
      example.event2
      example.event2_called.should == true
    end

  end

  describe "state_machine" do
    it "has a next_state method" do
      example = SimpleExample.new
      example.state_machine.next_state('event1').should == 'state2'
      example.state_machine.next_state('event2').should be_nil
    end
  end

end
