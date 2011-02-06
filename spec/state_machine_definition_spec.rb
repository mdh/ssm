require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'cgi'

describe SimpleStateMachine::StateMachineDefinition do

  before do
    @klass = Class.new do
      extend SimpleStateMachine
      def initialize(state = 'state1')
        @state = state
      end
      event :event1, :state1 => :state2, :state2 => :state3      
    end
    @smd = @klass.state_machine_definition
  end

  it "is inherited by subclasses" do
    example = Class.new(@klass).new
    example.should be_state1
    example.event1
    example.should be_state2
    example.event1
    example.should be_state3
  end

  describe "#transitions" do
    it "has a list of transitions" do
      @smd.transitions.should be_a(Array)
      @smd.transitions.first.should be_a(SimpleStateMachine::Transition)
    end
  end

  describe "#to_s" do
    it "converts to readable string format" do
      @smd.to_s.should =~ Regexp.new("state1.event1! => state2")
    end
  end

  describe "#to_graphiz_dot" do
    it "converts to graphiz dot format" do
      @smd.to_graphiz_dot.should =~ Regexp.new(%("state1"->"event1!"->"state2";))
      @smd.to_graphiz_dot.should =~ Regexp.new(%("state2"->" event1!"->"state3"))
    end
  end

  describe "#google_chart_url" do
    it "shows the state and event dependencies as a Google chart" do
      @smd.google_chart_url.should == "http://chart.googleapis.com/chart?cht=gv&chl=digraph{#{::CGI.escape @smd.to_graphiz_dot}}"
    end
  end
end

