module SimpleStateMachine
  module Decorator
    class ActiveRecord < SimpleStateMachine::Decorator::Default

      # decorates subject with:
      # * {event_name}_and_save
      # * {event_name}_and_save!
      # * {event_name}!
      # * {event_name}
      def decorate transition
        super transition
        event_name = transition.event_name.to_s
        decorate_save  event_name
        decorate_save! event_name
      end

      protected

        def decorate_save event_name
          event_name_and_save = "#{event_name}_and_save"
          unless @subject.method_defined?(event_name_and_save)
            @subject.send(:define_method, event_name_and_save) do |*args|
              old_state = self.send(self.class.state_machine_definition.state_method)
              send "#{event_name}_with_managed_state", *args
              if self.errors.entries.empty? && save
                true
              else
                self.send("#{self.class.state_machine_definition.state_method}=", old_state)
                false
              end
            end
            @subject.send :alias_method, "#{event_name}", event_name_and_save
          end
        end

        def decorate_save! event_name
          event_name_and_save_bang = "#{event_name}_and_save!"
          unless @subject.method_defined?(event_name_and_save_bang)
            @subject.send(:define_method, event_name_and_save_bang) do |*args|
              old_state = self.send(self.class.state_machine_definition.state_method)
              send "#{event_name}_with_managed_state", *args
              if self.errors.entries.empty?
                begin
                  save!
                rescue ::ActiveRecord::RecordInvalid
                  self.send("#{self.class.state_machine_definition.state_method}=", old_state)
                  raise #re raise
                end
              else
                self.send("#{self.class.state_machine_definition.state_method}=", old_state)
                raise ::ActiveRecord::RecordInvalid.new(self)
              end
            end
            @subject.send :alias_method, "#{event_name}!", event_name_and_save_bang
          end
        end

        def alias_event_methods event_name
          @subject.send :alias_method, "#{event_name}_without_managed_state", event_name
        end

        def define_state_setter_method; end

        def define_state_getter_method; end

    end
  end
end
