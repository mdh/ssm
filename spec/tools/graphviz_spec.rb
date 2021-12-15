require 'spec_helper'

describe SimpleStateMachine::Tools::Graphviz do

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

  describe "#to_graphviz_dot" do
    it "converts to graphviz dot format" do
      expect(@smd.to_graphviz_dot).to eq(%(digraph G {\n"state1"->"state2"[label=event1];\n"state2"->"state3"[label=event1]\n}))
    end
  end

  describe "#google_chart_url" do
    it "shows the state and event dependencies as a Google chart" do
      graph = @smd.transitions.map { |t| t.to_graphviz_dot }.sort.join(";")
      expect(@smd.google_chart_url).to eq("http://chart.googleapis.com/chart?cht=gv&chl=digraph{#{::CGI.escape graph}}")
    end
  end
end


