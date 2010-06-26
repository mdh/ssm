require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class WithoutEventMethods
  extend SimpleStateMachine

  def initialize
    set_initial_state(:unread)
  end

  event :view, :unread => :read
  
end

class WithPredefinedStateHelperMethods
  extend SimpleStateMachine

  def initialize
    set_initial_state(:unread)
  end
  
  def unread?
    raise "blah"
  end

  event :view, :unread => :read
  
end


describe SimpleStateMachine do
  
  it "should have a default state" do
    TrafficLight.new.state.should == 'green'
  end
  
  it "defines state_helper_methods for all states" do
    TrafficLight.new.green?.should == true
    TrafficLight.new.orange?.should == false
    TrafficLight.new.red?.should == false
  end
  
  it "does not define an state_helper_method if it already exists" do
    l = lambda { WithPredefinedStateHelperMethods.new.unread? }
    l.should raise_error(RuntimeError, 'blah')
  end
  
  it "defines an event method if it doesn't exist" do
    WithoutEventMethods.new.view
  end

end