module SimpleStateMachine::ActiveRecord

  include SimpleStateMachine::Mountable
  include SimpleStateMachine::Extendable
  include SimpleStateMachine::Inheritable

  class Decorator < SimpleStateMachine::Decorator

    # decorates subject with:
    # * {event_name}_and_save
    # * {event_name}_and_save!
    # * {event_name}!
    # * {event_name}
    def decorate transition
      super transition
      event_name = transition.event_name.to_s
      event_name_and_save = "#{event_name}_and_save"
      unless @subject.method_defined?(event_name_and_save)
        @subject.send(:define_method, event_name_and_save) do |*args|
          old_state = self.send(self.class.state_machine_definition.state_method)
          send "with_managed_state_#{event_name}", *args
          if !self.errors.entries.empty?
            self.send("#{self.class.state_machine_definition.state_method}=", old_state)
            return false
          else
            if save
              return true
            else
              self.send("#{self.class.state_machine_definition.state_method}=", old_state)
              return false
            end
          end
        end
        @subject.send :alias_method, "#{transition.event_name}", event_name_and_save
      end
      event_name_and_save_bang = "#{event_name_and_save}!"
      unless @subject.method_defined?(event_name_and_save_bang)
        @subject.send(:define_method, event_name_and_save_bang) do |*args|
          old_state = self.send(self.class.state_machine_definition.state_method)
          send "with_managed_state_#{event_name}", *args
          if !self.errors.entries.empty?
            self.send("#{self.class.state_machine_definition.state_method}=", old_state)
            raise ActiveRecord::RecordInvalid.new(self)
          end
          begin
            save!
          rescue ActiveRecord::RecordInvalid
            self.send("#{self.class.state_machine_definition.state_method}=", old_state)
            raise #re raise
          end
        end
        @subject.send :alias_method, "#{transition.event_name}!", event_name_and_save_bang
      end
    end

    protected

      def alias_event_methods event_name
        @subject.send :alias_method, "without_managed_state_#{event_name}", event_name
      end

      def define_state_setter_method; end

      def define_state_getter_method; end

  end

  def state_machine_definition
    unless @state_machine_definition
      @state_machine_definition = SimpleStateMachine::StateMachineDefinition.new
      @state_machine_definition.lazy_decorator = lambda { Decorator.new(self) }
    end
    @state_machine_definition
  end
end
