require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class SimpleExample
  extend SimpleStateMachine
  def initialize
    self.state = 'state1'
  end
  event :event1, :state1 => :state2
  def event2
    'event2'
  end
  event :event2, :state2 => :state3
end

describe SimpleStateMachine do
  
  it "has a default state nil" do
    SimpleExample.new.state.should == 'state1'
  end

  describe "events" do
    it "raises an error if an invalid state_transition is called" do
      example = SimpleExample.new
      lambda { example.event2 }.should raise_error(RuntimeError, "You cannot 'event2' when state is 'state1'")
    end

    it "returns the event_method return statement" do
      example = SimpleExample.new
      example.event1.should be_nil
      example.event2.should == 'event2'
    end

  end

end