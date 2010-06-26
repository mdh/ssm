class Lamp
      
  extend SimpleStateMachine

  def initialize
    self.state = 'off'
  end
  
  def push_button1
    puts 'click1'
    puts state
  end
  event :push_button1, :off => :on, 
                       :on  => :off
  
  def push_button2
    puts 'click2'
    puts state
  end
  event :push_button2, :off => :on,
                       :on  => :off

end