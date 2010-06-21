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
  attr_reader :state
  extend SimpleStateMachine

  def initialize
    @state = :unread
  end

  def view; end
  event :view, :unread => :read

  def close; end
  event :close, :unread => :closed,
                :read   => :closed

end