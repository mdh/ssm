module SimpleStateMachine::ActiveRecord

  include SimpleStateMachine::EventMixin
  
  def state_machine_decorator
    Decorator
  end

  class Decorator < SimpleStateMachine::Decorator

    def decorate event_name, from, to
      super event_name, from, to
      unless @subject.method_defined?("#{event_name}_and_save")
        @subject.send(:define_method, "#{event_name}_and_save") do |*args|
          old_state = state
          send "#{event_name}", *args
          if save
            return true
          else
            self.state = old_state
            return false
          end
        end
      end
      unless @subject.method_defined?("#{event_name}_and_save!")
        @subject.send(:define_method, "#{event_name}_and_save!") do |*args|
          old_state = state
          send "#{event_name}", *args
          if !self.errors.entries.empty?
            self.state = old_state
            raise ActiveRecord::RecordInvalid.new(self)
          end
          begin
            save!
          rescue ActiveRecord::RecordInvalid
            self.state = old_state
            raise
          end
        end
      end
    end
  
    private

    def define_state_setter_method; end

    def define_state_getter_method; end

  end

end
