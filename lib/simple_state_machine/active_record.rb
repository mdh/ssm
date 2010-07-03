module SimpleStateMachine::ActiveRecord

  include SimpleStateMachine::EventMixin
  
  def new_state_machine_definition
    SimpleStateMachine::StateMachineDefinition.new(self, Decorator)
  end

  class StateMachine < SimpleStateMachine::StateMachine
  
    def next_state(event_name)
      if event_name =~ /\!$/
        event_name = event_name.chop
      end
      super event_name
    end

    def transition(event_name)
      if to = next_state(event_name)
        if with_error_counting { yield } > 0 || @subject.invalid?
          if event_name =~ /\!$/
            raise ::ActiveRecord::RecordInvalid.new(@subject)
          else
            return false
          end
        else
          @subject.state = to
          if event_name =~ /\!$/
            @subject.save! #TODO maybe save_without_validation!
          else
            @subject.save
          end
        end
      else
        illegal_event_callback event_name
      end
    end

    private

      def with_error_counting
        original_errors_size =  @subject.errors.size
        yield
        @subject.errors.size - original_errors_size
      end

  end

  class Decorator < SimpleStateMachine::Decorator

    def decorate event_name, from, to
      super event_name, from, to
      unless @subject.method_defined?("#{event_name}!")
        @subject.send(:define_method, "#{event_name}!") do |*args|
          send "#{event_name}", *args
        end
      end
      decorate_event_method("#{event_name}!")
    end
  
    private
  
    def define_state_machine_method
      @subject.send(:define_method, "state_machine") do
        @state_machine ||= StateMachine.new(self)
      end
    end

    def define_state_setter_method; end

    def define_state_getter_method; end

  end

end