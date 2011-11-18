module SimpleStateMachine

  class IllegalStateTransitionError < ::RuntimeError; end

  ##
  # Defines the state machine used by the instance
  class StateMachine
    attr_reader :raised_error

    def initialize(subject)
      @subject = subject
    end

    # Returns the next state for the subject for event_name
    def next_state(event_name)
      transition = transitions.select{|t| t.is_transition_for?(event_name, @subject.send(state_method))}.first
      transition ? transition.to : nil
    end

    # Returns the error state for the subject for event_name and error
    def error_state(event_name, error)
      transition = transitions.select{|t| t.is_error_transition_for?(event_name, error) }.first
      transition ? transition.to : nil
    end

    # Transitions to the next state if next_state exists.
    # When an error occurs, it uses the error to determine next state.
    # If no next state can be determined it transitions to the default error
    # state if defined, otherwise the error is re-raised.
    # Calls illegal_event_callback event_name if no next_state is found
    def transition(event_name)
      clear_raised_error
      if to = next_state(event_name)
        begin
          result = yield
        rescue => e
          error_state = error_state(event_name, e) ||
            state_machine_definition.default_error_state
          if error_state
            @raised_error = e
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

      def clear_raised_error
        @raised_error = nil
      end

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
        raise IllegalStateTransitionError.new("You cannot '#{event_name}' when state is '#{@subject.send(state_method)}'")
      end

  end
end
