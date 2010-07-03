module SimpleStateMachine
  
  module EventMixin

    def event event_name, state_transitions
      state_machine_definition.define_event event_name, state_transitions
    end

    def state_machine_definition
      @state_machine_definition ||= new_state_machine_definition
    end

  end

  include EventMixin
  
  def new_state_machine_definition
    StateMachineDefinition.new(self, Decorator)
  end
  
  class StateMachineDefinition

    def initialize subject, decorator_class
      @decorator = decorator_class.new(subject)
    end
    
    def define_event event_name, state_transitions
      state_transitions.each do |from, to|
        add_transition(event_name, from, to)
        @decorator.decorate(event_name, from, to)
      end
    end

    def transitions
      @transitions ||= {}
    end
    
    def add_transition event_name, from, to
      transitions[event_name.to_s] ||= {}
      transitions[event_name.to_s][from.to_s] = to.to_s
    end

  end
  
  class StateMachine

    def initialize(subject)
      @subject = subject
    end
  
    def next_state(event_name)
      transitions[event_name.to_s][@subject.state]
    end
  
    def transition(event_name)
      if to = next_state(event_name)
        result = yield
        @subject.state = to
        return result
      else
        illegal_event_callback event_name
      end
    end
  
    private
    
      def transitions
        @subject.class.state_machine_definition.transitions
      end

      def illegal_event_callback event_name
        # override with your own implementation, like setting errors in your model
        raise "You cannot '#{event_name}' when state is '#{@subject.state}'"
      end
  
  end

  class Decorator

    def initialize(subject)
      @subject = subject
      define_state_machine_method
      define_state_getter_method
      define_state_setter_method
    end

    def decorate event_name, from, to
      define_state_helper_method(from)
      define_state_helper_method(to)
      define_event_method(event_name)
      decorate_event_method(event_name)
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
            self.state == state.to_s
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
        unless @subject.method_defined?('state=')
          @subject.send(:define_method, 'state=') do |new_state|
            @state = new_state.to_s
          end
        end
      end

      def define_state_getter_method
        unless @subject.method_defined?('state')
          @subject.send(:define_method, 'state') do
            @state
          end
        end
      end

  end

end