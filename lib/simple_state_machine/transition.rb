module SimpleStateMachine
  # Defines transitions for events
  class Transition
    attr_reader :event_name, :from, :to
    def initialize(event_name, from, to)
      @event_name = event_name.to_s
      @from       = from.is_a?(Class) ? from : from.to_s
      @to         = to.to_s
    end

    # returns true if it's a transition for event_name
    def is_transition_for?(event_name, subject_state)
      is_same_event?(event_name) && is_same_from?(subject_state)
    end

    # returns true if it's a error transition for event_name and error
    def is_error_transition_for?(event_name, error)
      is_same_event?(event_name) && from.is_a?(Class) && error.is_a?(from)
    end

    def to_s
      "#{from}.#{event_name}! => #{to}"
    end

    # TODO move to Graphiz module
    def to_graphviz_dot
      %("#{from}"->"#{to}"[label=#{event_name}])
    end

    private

      def is_same_event?(event_name)
        self.event_name == event_name.to_s
      end

      def is_same_from?(subject_from)
        from.to_s == 'all' || subject_from.to_s == from.to_s
      end
  end
end
