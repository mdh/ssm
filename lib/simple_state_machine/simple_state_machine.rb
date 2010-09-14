module SimpleStateMachine
  
  class Error < ::RuntimeError
  end

  ##
  # Adds state machine methods to the extended class 
  module StateMachineMixin

    # mark the method as an event and specify how the state should transition 
    def event event_name, state_transitions
      state_transitions.each do |froms, to|
        [froms].flatten.each do |from|
          transition = state_machine_definition.add_transition(event_name, from, to)
          state_machine_decorator(self).decorate(transition)
        end
      end
    end

    def state_machine_definition
      @state_machine_definition ||= StateMachineDefinition.new
    end

    def state_machine_definition= state_machine_definition
      @state_machine_definition = state_machine_definition
      state_machine_definition.transitions.each do |transition|
        state_machine_decorator(self).decorate(transition)
      end
    end
    
    def state_machine_decorator subject
      Decorator.new subject
    end

    def inherited(subclass)
      subclass.state_machine_definition = state_machine_definition.clone
      super
    end
  end

  include StateMachineMixin
  
  ##
  # Defines state machine transitions
  class StateMachineDefinition

    attr_writer :state_method

    def transitions
      @transitions ||= []
    end
    
    def add_transition event_name, from, to
      transition = Transition.new(event_name, from, to)
      transitions << transition
      transition
    end
     
    def state_method
      @state_method ||= :state
    end      
  end
  
  ##
  # Defines the state machine used by the instance
  class StateMachine

    def initialize(subject)
      @subject = subject
    end

    # Returns the next state for the subject for event_name
    def next_state(event_name)
      transition = transitions.select{|t| t.is_transition_for?(event_name) && @subject.send(state_method).to_s == t.from.to_s}.first
      transition ? transition.to : nil
    end

    # Returns the error state for the subject for event_name and error
    def error_state(event_name, error)
      transition = transitions.select{|t| t.is_error_transition_for?(event_name, error) }.first
      transition ? transition.to : nil
    end

    # Transitions to the next state if next_state exists.
    # Calls illegal_event_callback event_name if no next_state is found
    def transition(event_name)
      if to = next_state(event_name)
        begin
          result = yield
        rescue => e
          if error_state = error_state(event_name, e)
            @subject.send("#{state_method}=", error_state)
            return result
          else
            raise
          end
        end
        # TODO refactor out to AR module
        if defined?(::ActiveRecord) && @subject.is_a?(::ActiveRecord::Base)
          if @subject.errors.entries.empty?
            @subject.send("#{state_method}=", to)
            return true
          else
            return false
          end
        else
          @subject.send("#{state_method}=", to)
          return result
        end
      else
        illegal_event_callback event_name
      end
    end
  
    private
      
      def state_machine_definition
        @subject.class.state_machine_definition
      end

      def transitions
        state_machine_definition.transitions
      end

      def state_method
        state_machine_definition.state_method
      end

      # override with your own implementation, like setting errors in your model
      def illegal_event_callback event_name
        raise Error.new("You cannot '#{event_name}' when state is '#{@subject.send(state_method)}'")
      end
  
  end

  ##
  # Defines transitions for events
  class Transition 
    attr_reader :event_name, :from, :to
    def initialize(event_name, from, to)
      @event_name = event_name.to_s
      @from       = from.is_a?(Class) ? from : from.to_s
      @to         = to.to_s
    end

    # returns true if it's a transition for event_name
    def is_transition_for?(event_name)
      self.event_name == event_name.to_s
    end

    # returns true if it's a error transition for event_name and error
    def is_error_transition_for?(event_name, error)
      is_transition_for?(event_name) && error.class == from
    end
  end

  ##
  # Decorates @subject with methods to access the state machine
  class Decorator

    def initialize(subject)
      @subject = subject
      define_state_machine_method
      define_state_getter_method
      define_state_setter_method
    end

    def decorate transition
      define_state_helper_method(transition.from)
      define_state_helper_method(transition.to)
      define_event_method(transition.event_name)
      decorate_event_method(transition.event_name)
    end

    private

      def define_state_machine_method
        @subject.send(:define_method, "state_machine") do
          @state_machine ||= StateMachine.new(self)
        end
      end

      def define_state_helper_method state
        unless @subject.method_defined?("#{state.to_s}?")
          @subject.send(:define_method, "#{state.to_s}?") do
            self.send(self.class.state_machine_definition.state_method) == state.to_s
          end
        end
      end

      def define_event_method event_name
        unless @subject.method_defined?("#{event_name}")
          @subject.send(:define_method, "#{event_name}") {}
        end
      end

      def decorate_event_method event_name
        # TODO put in transaction for activeRecord?
        unless @subject.method_defined?("with_managed_state_#{event_name}")
          @subject.send(:define_method, "with_managed_state_#{event_name}") do |*args|
            return state_machine.transition(event_name) do
              send("without_managed_state_#{event_name}", *args)
            end
          end
          @subject.send :alias_method, "without_managed_state_#{event_name}", event_name
          @subject.send :alias_method, event_name, "with_managed_state_#{event_name}"
        end
      end

      def define_state_setter_method
        unless @subject.method_defined?("#{state_method}=")
          @subject.send(:define_method, "#{state_method}=") do |new_state|
            instance_variable_set(:"@#{self.class.state_machine_definition.state_method}", new_state)
          end
        end
      end

      def define_state_getter_method
        unless @subject.method_defined?(state_method)
          @subject.send(:attr_reader, state_method)
        end
      end

    protected

      def state_method
        @subject.state_machine_definition.state_method
      end
  end

end
