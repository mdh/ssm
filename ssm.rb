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
          if @__cancel_state_transition
            @__cancel_state_transition = false
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
    
    def cancel_state_transition
      @__cancel_state_transition = true
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
    @state = :new
  end

  def send_activation_code
    self.activation_code = SHA::Digest.hexdigest("salt #{Time.now.to_f}")
    if send_activation_email(self.activation_code)
      self.activation_code
    else
      cancel_state_transition
      self.activation_code = nil
    end
  end
  event :send_activation_code, :new => :waiting_for_activation
    
  def confirm_activation_code activation_code
    if self.activation_code != activation_code
      self.errors[:activation_code] = "Invalid" 
    end
  end
  event :confirm_activation_code, :waiting_for_activation => :active
  
  def log_send_activation_code_failed
  end
  event :log_send_activation_code_failed, :new => :send_activation_code_failed

  def reset_password(new_password)
    self.password = new_password
  end
  # do not change state, but ensure that we are in proper state
  event :reset_password, :active => :active
  
  def state
    @state
  end
  
end

user = User.new
user.state.should == :new

if user.send_activation_code '123'
  user.state.should == :waiting_for_activation
else
  user.log_email_error
  user.state.should == :send_activation_code_failed
end  

# raises error
user.reset_password('foo')
# user.errors['state'].should == 'cannot reset_password if waiting_for_activation'

user.confirm_activation_code '123'
user.state.should == :active

user.reset_password('foo')
user.state.should == :active