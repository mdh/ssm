# Implementation of the AASM Conversation
#
# class Conversation
#   include AASM
#
#   aasm_column :current_state # defaults to aasm_state
#
#   aasm_initial_state :unread
#
#   aasm_state :unread
#   aasm_state :read
#   aasm_state :closed
#
#   aasm_event :view do
#     transitions :to => :read, :from => [:unread]
#   end
#
#   aasm_event :close do
#     transitions :to => :closed, :from => [:read, :unread]
#   end
# end

class Conversation
  extend SimpleStateMachine

  def initialize
    self.state = 'unread'
  end

  event :view,  :unread => :read
  event :close, :all    => :closed

end
