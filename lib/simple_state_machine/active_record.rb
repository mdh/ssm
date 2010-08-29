module SimpleStateMachine::ActiveRecord

  include SimpleStateMachine::EventMixin
  
  def state_machine_decorator subject
    Decorator.new subject
  end

  class Decorator < SimpleStateMachine::Decorator

    def decorate transition
      super transition
      unless @subject.method_defined?("#{transition.event_name}_and_save")
        @subject.send(:define_method, "#{transition.event_name}_and_save") do |*args|
          old_state = state
          send "#{transition.event_name}", *args
          if !self.errors.entries.empty?
            self.state = old_state
            return false
          else
            if save
              return true
            else
              self.state = old_state
              return false
            end
          end
        end
      end
      unless @subject.method_defined?("#{transition.event_name}_and_save!")
        @subject.send(:define_method, "#{transition.event_name}_and_save!") do |*args|
          old_state = state
          send "#{transition.event_name}", *args
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
        @subject.send :alias_method, "#{transition.event_name}!", "#{transition.event_name}_and_save!"
      end
    end
  
    private

    def define_state_setter_method; end

    def define_state_getter_method; end

  end

end
