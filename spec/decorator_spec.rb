require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class WithoutEventMethods
  extend SimpleStateMachine

  def initialize
    self.state = 'unread'
  end
  event :view, :unread => :read
  
end

class WithPredefinedStateHelperMethods
  extend SimpleStateMachine

  def initialize
    self.state = 'unread'
  end
  event :view, :unread => :read

  def unread?
    raise "blah"
  end
end


describe SimpleStateMachine::Decorator do

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