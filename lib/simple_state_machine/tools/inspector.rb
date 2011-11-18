module SimpleStateMachine
  module Tools
    module Inspector
      def begin_states
        from_states - to_states
      end

      def end_states
        to_states - from_states
      end

      def states
        (to_states + from_states).uniq
      end

      private

        def from_states
          to_uniq_sym(sample_transitions.map(&:from))
        end

        def to_states
          to_uniq_sym(sample_transitions.map(&:to))
        end

        def to_uniq_sym(array)
          array.map { |state| state.is_a?(String) ? state.to_sym : state }.uniq
        end

        def sample_transitions
          (@subject || sample_subject).state_machine_definition.send :transitions
        end

        def sample_subject
          self_class = self.class
          sample = Class.new do
            extend SimpleStateMachine::Mountable
            mount_state_machine self_class
          end
          sample
        end
    end
  end
end
