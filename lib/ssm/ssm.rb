module SimpleStateMachine
  
  def event event_name, state_transitions
    @state_machine ||= StateMachine.new self
    @state_machine.register_event event_name, state_transitions
  end
  
  def state_machine
    @state_machine
  end
  
  class StateMachine
    
    attr_reader :events

    def initialize subject
      @subject = subject
      @events  = {}
    end
    
    def register_event event_name, state_transitions
      @events[event_name] ||= {}
      state_transitions.each do |from, to|
        @events[event_name][from] = to
        unless @subject.method_defined?("with_managed_state_#{event_name}")
          decorate_event_method(event_name) 
        end
      end
    end

    def decorate_event_method event_name
      @subject.send(:define_method, "with_managed_state_#{event_name}") do |*args|
        state_machine  = self.class.state_machine
        if @next_state = state_machine.events[event_name][@state]
          result = send("without_managed_state_#{event_name}", *args)
          if @__cancel_state_transition
            @__cancel_state_transition = false
          else
            @state = @next_state
            send :state_transition_succeeded_callback
          end
        else
          # implement your own logic: i.e. set errors in active validations
          send :illegal_state_transition_callback, event_name
        end
        result
      end
      @subject.send :alias_method, "without_managed_state_#{event_name}", event_name
      @subject.send :alias_method, event_name, "with_managed_state_#{event_name}"
      @subject.send :include, InstanceMethods
    end
    
  end
  
  module InstanceMethods
  
    def illegal_state_transition_callback event_name
      # override with your own implementation, like setting errors in your model
      raise "You cannot '#{event_name}' when state is '#{@state}'"
    end
  
    def state_transition_succeeded_callback
    end
    
    def cancel_state_transition
      @__cancel_state_transition = true
    end
  
  end
  
end