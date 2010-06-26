require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class SimpleExample
  extend SimpleStateMachine
  event :event1, nil     => :state1
  event :event2, :state1 => :state2
end

describe SimpleStateMachine do
  
  it "has a default state nil" do
    #SimpleExample.new.state.should be_nil
  end

end