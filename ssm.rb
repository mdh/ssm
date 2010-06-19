module SimpleStateMachine
  
  def event event_name, state_transitions
    @state_machine ||= StateMachine.new self
    @state_machine.register_events event_name, state_transitions
  end
  
  def state_machine
    @state_machine
  end
  
  class StateMachine
    
    def initialize subject
      @subject = subject
      @events  = {}      
    end
    
    def register_events event_name, state_transitions
      state_transitions.each do |from, to|
        @events[event_name]     ||= {}
        @events[event_name][from] = to
        unless @subject.method_defined?("with_managed_state_#{event_name}")
          alias_event_method(event_name) 
        end
      end
    end

    def alias_event_method event_name
      @subject.send(:define_method, "with_managed_state_#{event_name}") do |*args|
        state_machine  = self.class.state_machine
        if @next_state = state_machine.events[event_name][@state]
          result = send("without_managed_state_#{event_name}", *args)
          if @__cancel_event
            @__cancel_event = false
          else
            @state = @next_state
            send :state_transition_succeeded_callback
          end
        else
          # implement your own logic: i.e. set errors in active validations
          send :illegal_state_transition_callback, event_name
        end
        result
      end
      @subject.send :alias_method, "without_managed_state_#{event_name}", event_name
      @subject.send :alias_method, event_name, "with_managed_state_#{event_name}"
      @subject.send :include, InstanceMethods
    end

    def events
      @events
    end

    def initial_state state
      @state = state
    end
  end
  
  module InstanceMethods
  
    def illegal_state_transition_callback event_name
      # override with your own implementation, like setting errors in your model
      raise "You cannot '#{event_name}' when state is '#{@state}'"
    end
  
    def state_transition_succeeded_callback
    end
    
    def cancel_event
      @__cancel_event = true
    end
  
  end
  
end

class TrafficLight

  extend SimpleStateMachine
  
  def initialize
    @state = :green
  end

  # state machine events
  def change_state
    puts "#{@state} => #{@next_state}"
  end

  event :change_state, :green  => :orange,
                       :orange => :red,
                       :red    => :green
end

tl = TrafficLight.new
4.times do
  tl.change_state
end

class Lamp
  
  extend SimpleStateMachine

  def initialize
    @state = :off
  end
  
  def push_button1
    puts 'click1'
    puts @state
  end
  event :push_button1, :off => :on, 
                       :on  => :off
  
  def push_button2
    puts 'click2'
    puts @state
  end
  event :push_button2, :off => :on,
                       :on  => :off

end

l = Lamp.new
4.times do
  l.push_button1
  l.push_button2
end


class User
  
  extend SimpleStateMachine

  def initialize
    @state = :signed_up
  end

  def confirm_activation_code activation_code
    if self.activation_code != activation_code
      self.errors[:activation_code] = "Invalid" 
    end
  end
  event :confirm_activation_code, :signed_up => :sign_up_complete
  
  def send_passord_change_confirmation
    if send_email
      true
    else
      cancel_event
      false
    end
  end
  event :send_passord_change_confirmation, :sign_up_complete => :changing_password

  def log_email_error
  end
  event :log_email_error, :sign_up_complete => :send_email_failed
  
  def reset_password(with_managed_state_password)
    self.password = with_managed_state_password
  end
  event :reset_password, :changing_password => :sign_up_complete
  
  
  def cancel_reset
    # do nothing
  end
  event :cancel_reset, :changing_password => :sign_up_complete

  def state
    @state
  end
  
end

user = User.new
puts user.state

# raises error
user.reset_password('foo')
user.errors['state'].should == 'cannot reset_password if signed_up'

user.confirm_activation_code '123'
user.state.should == :sign_up_complete

if user.send_passord_change_confirmation
else
  user.log_email_error
end

user.send_passord_change_confirmation
user.state.should == :changing_password

user.reset_password('foo')
user.state.should == :sign_up_complete