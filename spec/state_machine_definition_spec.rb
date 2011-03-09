require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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

  describe '#state_method' do
    subject do
      klass = Class.new do
        attr_reader :ssm_state
        extend SimpleStateMachine
        state_machine_definition.state_method = :ssm_state

        def initialize(state = 'state1')
          @ssm_state = state
        end
        event :event1, :state1 => :state2
        event :event2, :state2 => :state3
      end
      klass.new
    end

    it "is used when changing state" do
      subject.ssm_state.should == 'state1'
      subject.event1
      subject.ssm_state.should == 'state2'
      subject.event2
      subject.ssm_state.should == 'state3'
    end

    it "works with state helper methods" do
      subject.should be_state1
      subject.event1
      subject.should be_state2
      subject.event2
      subject.should be_state3
    end

    it "raise an error if an invalid state_transition is called" do
      lambda { subject.event2 }.should raise_error(SimpleStateMachine::IllegalStateTransitionError, "You cannot 'event2' when state is 'state1'")
    end

  end

  describe ".begin_states" do
    before do
      @klass = Class.new(SimpleStateMachine::StateMachineDefinition) do
        def initialize(subject)
          self.lazy_decorator = lambda { SimpleStateMachine::Decorator.new(subject) }
          define_event(:event_a, :state1 => :state2)
          define_event(:event_b, :state2 => :state3)
          define_event(:event_c, :state1 => :state3)
        end
      end
    end

    it "returns all 'from' states that aren't 'to' states" do
      @klass.begin_states.should == [:state1]
    end
  end

  describe ".end_states" do
    before do
      @klass = Class.new(SimpleStateMachine::StateMachineDefinition) do
        def initialize(subject)
          self.lazy_decorator = lambda { SimpleStateMachine::Decorator.new(subject) }
          define_event(:event_a, :state1 => :state2)
          define_event(:event_b, :state2 => :state3)
          define_event(:event_c, :state1 => :state3)
        end
      end
    end

    it "returns all 'to' states that aren't 'from' states" do
      @klass.end_states.should == [:state3]
    end
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
      @smd.to_graphiz_dot.should ==  %("state1"->"state2"[label=event1];"state2"->"state3"[label=event1])
    end
  end

  describe "#google_chart_url" do
    it "shows the state and event dependencies as a Google chart" do
      puts "http://chart.googleapis.com/chart?cht=gv&chl=digraph{#{::CGI.escape @smd.to_graphiz_dot}}"
      @smd.google_chart_url.should == "http://chart.googleapis.com/chart?cht=gv&chl=digraph{#{::CGI.escape @smd.to_graphiz_dot}}"
    end
  end
end

