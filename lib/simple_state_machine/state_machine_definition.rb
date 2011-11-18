module SimpleStateMachine
  ##
  # Defines state machine transitions
  class StateMachineDefinition

    attr_writer :default_error_state, :state_method, :subject, :decorator,
                :decorator_class

    def decorator
      @decorator ||= decorator_class.new(@subject)
    end

    def decorator_class
      @decorator_class ||= Decorator::Default
    end

    def default_error_state
      @default_error_state && @default_error_state.to_s
    end

    def transitions
      @transitions ||= []
    end

    def define_event event_name, state_transitions
      state_transitions.each do |froms, to|
        [froms].flatten.each do |from|
          add_transition(event_name, from, to)
        end
      end
    end

    def add_transition event_name, from, to
      transition = Transition.new(event_name, from, to)
      transitions << transition
      decorator.decorate(transition)
    end

    def state_method
      @state_method ||= :state
    end

    # Human readable format: old_state.event! => new_state
    def to_s
      transitions.map(&:to_s).join("\n")
    end

    module Mountable
      def event event_name, state_transitions
        events << [event_name, state_transitions]
      end

      def events
        @events ||= []
      end

      module InstanceMethods
        def add_events
          self.class.events.each do |event_name, state_transitions|
            define_event event_name, state_transitions
          end
        end
      end
    end
    extend Mountable
    include Mountable::InstanceMethods

    # TODO only include in rake task?
    include ::SimpleStateMachine::Tools::Graphviz
    include ::SimpleStateMachine::Tools::Inspector
  end
end
