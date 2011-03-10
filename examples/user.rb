require 'digest/sha1'
class User < ActiveRecord::Base

  validates_presence_of :name

  extend SimpleStateMachine::ActiveRecord

  def after_initialize
    self.state ||= 'new'
    # if you get an ActiveRecord::MissingAttributeError
    # you'll probably need to do (http://bit.ly/35q23b):
    #   write_attribute(:ssm_state, "pending") unless read_attribute(:ssm_state)
  end

  def invite
    self.activation_code = Digest::SHA1.hexdigest("salt #{Time.now.to_f}")
    send_activation_email(self.activation_code)
  end
  event :invite, :new => :invited

  def confirm_invitation activation_code
    if self.activation_code != activation_code
      errors.add 'activation_code', 'is invalid'
    end
  end
  event :confirm_invitation, :invited => :active

  #event :log_send_activation_code_failed, :new => :send_activation_code_failed
  #
  # def reset_password(new_password)
  #   self.password = new_password
  # end
  # # do not change state, but ensure that we are in proper state
  # event :reset_password, :active => :active

  def send_activation_email(code)
    true
  end

end
