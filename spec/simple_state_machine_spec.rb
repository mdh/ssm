require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'cgi'

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
  event :event_with_multiple_from, [:state1, :state2] => :state3
  event :event_from_all, :all => :state3
end

class SimpleExampleWithCustomStateMethod
  extend SimpleStateMachine
  state_machine_definition.state_method = :ssm_state

  def initialize(state = 'state1')
    @ssm_state = state
  end
  event :event1, :state1 => :state2
  event :event2, :state2 => :state3
end

describe SimpleStateMachine do
 
  it "has an error that extends RuntimeError" do
    SimpleStateMachine::IllegalStateTransitionError.superclass.should == RuntimeError
  end

  it "has a default state" do
    SimpleExample.new.state.should == 'state1'
  end

  describe "events" do

    it "changes state if event has multiple transitions" do
      example = SimpleExample.new
      example.should be_state1
      example.event1
      example.should be_state2
      example.event1
      example.should be_state3
    end

    it "changes state if event has multiple froms" do
      example = SimpleExample.new
      example.event_with_multiple_from
      example.should be_state3
      example = SimpleExample.new 'state2'
      example.should be_state2
      example.event_with_multiple_from
      example.should be_state3
    end

    it "changes state if event has all as from" do
      example = SimpleExample.new
      example.event_from_all
      example.should be_state3
      example = SimpleExample.new 'state2'
      example.should be_state2
      example.event_from_all
      example.should be_state3
    end

    it "changes state when state is a symbol instead of a string" do
      example = SimpleExample.new :state1
      example.state.should == :state1
      example.send(:event1)
      example.should be_state2
    end

    it "changes state to error_state when error should be caught" do
      class_with_error = Class.new(SimpleExample)
      class_with_error.instance_eval do
        define_method :raise_error do
          raise RuntimeError.new
        end
        event :raise_error, :state1 => :state2, RuntimeError => :failed
      end
      example = class_with_error.new
      example.should be_state1
      example.raise_error
      example.should be_failed
    end
    
    it "raise an error if an invalid state_transition is called" do
      example = SimpleExample.new
      lambda { example.event2 }.should raise_error(SimpleStateMachine::IllegalStateTransitionError, "You cannot 'event2' when state is 'state1'")
    end

    it "returns what the decorated method returns" do
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

  describe 'custom state method' do
    
    it "changes state when calling events" do
      example = SimpleExampleWithCustomStateMethod.new
      example.should be_state1
      example.event1
      example.should be_state2
      example.event2
      example.should be_state3
    end    
    
    it "raise an error if an invalid state_transition is called" do
      example = SimpleExampleWithCustomStateMethod.new
      lambda { example.event2 }.should raise_error(SimpleStateMachine::IllegalStateTransitionError, "You cannot 'event2' when state is 'state1'")
    end

  end

  describe "state_machine_definition" do

    it "is inherited by subclasses" do
      example = Class.new(SimpleExample).new
      example.should be_state1
      example.event1
      example.should be_state2
      example.event1
      example.should be_state3
    end

    it "has a list of transitions" do
      smd = SimpleExample.state_machine_definition
      smd.transitions.should be_a(Array)
      smd.transitions.first.should be_a(SimpleStateMachine::Transition)
    end

    it "converts to readable string format" do
      smd = SimpleExample.state_machine_definition
      smd.to_s.should =~ Regexp.new("state1.event1! => state2")
    end

    it "converts to graphiz dot format" do
      smd = SimpleExample.state_machine_definition
      smd.to_graphiz_dot.should =~ Regexp.new(%("state1"->"event1!"->"state2";))
      smd.to_graphiz_dot.should =~ Regexp.new(%("state2"->" event1!"->"state3";))
    end

    it "shows the state and event dependencies as a Google chart" do
      smd = SimpleExample.state_machine_definition
      smd.google_chart_url.should == "http://chart.googleapis.com/chart?cht=gv&chl=digraph{#{::CGI.escape smd.to_graphiz_dot}}"
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

