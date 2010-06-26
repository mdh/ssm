require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class SimpleExample
  extend SimpleStateMachine
  event :event1, nil     => :state1
  event :event2, :state1 => :state2
  event :event3, :state2 => :state3
end

describe SimpleStateMachine do
  
  it "has a default state nil" do
    SimpleExample.new.state.should be_nil
  end

  it "raises an error if an invalid state_transition is called" do
    example = SimpleExample.new
    lambda { example.event2 }.should raise_error(RuntimeError, "You cannot 'event2' when state is ''")
  end

end