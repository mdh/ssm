module SimpleStateMachine
  module Decorator
    ##
    # Decorates @subject with methods to access the state machine
    class Default

      attr_writer :subject
      def initialize(subject)
        @subject = subject
      end

      def decorate transition
        define_state_machine_method
        define_state_getter_method
        define_state_setter_method

        define_state_helper_method(transition.from)
        define_state_helper_method(transition.to)
        define_event_method(transition.event_name)
        decorate_event_method(transition.event_name)
      end

      private

        def define_state_machine_method
          unless any_method_defined?("state_machine")
            @subject.send(:define_method, "state_machine") do
              @state_machine ||= StateMachine.new(self)
            end
          end
        end

        def define_state_helper_method state
          unless any_method_defined?("#{state.to_s}?")
            @subject.send(:define_method, "#{state.to_s}?") do
              self.send(self.class.state_machine_definition.state_method) == state.to_s
            end
          end
        end

        def define_event_method event_name
          unless any_method_defined?("#{event_name}")
            @subject.send(:define_method, "#{event_name}") {}
          end
        end

        def decorate_event_method event_name
          # TODO put in transaction for activeRecord?
          unless @subject.method_defined?("#{event_name}_with_managed_state")
            @subject.send(:define_method, "#{event_name}_with_managed_state") do |*args|
              return state_machine.transition(event_name) do
                send("#{event_name}_without_managed_state", *args)
              end
            end
            alias_event_methods event_name
          end
        end

        def define_state_setter_method
          unless any_method_defined?("#{state_method}=")
            @subject.send(:define_method, "#{state_method}=") do |new_state|
              instance_variable_set(:"@#{self.class.state_machine_definition.state_method}", new_state)
            end
          end
        end

        def define_state_getter_method
          unless any_method_defined?(state_method)
            @subject.send(:attr_reader, state_method)
          end
        end

        def any_method_defined?(method)
          @subject.method_defined?(method) ||
          @subject.protected_method_defined?(method) ||
          @subject.private_method_defined?(method)
        end

      protected

        def alias_event_methods event_name
          @subject.send :alias_method, "#{event_name}_without_managed_state", event_name
          @subject.send :alias_method, event_name, "#{event_name}_with_managed_state"
        end

        def state_method
          @subject.state_machine_definition.state_method
        end
    end
  end
end
