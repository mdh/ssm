require 'digest/sha1'
class User
  
  attr_accessor :activation_code
  
  extend SimpleStateMachine

  def initialize
    @state = 'new'
  end

  def send_activation_code
    self.activation_code = Digest::SHA1.hexdigest("salt #{Time.now.to_f}")
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
  
  def send_activation_email(code)
    true
  end

end