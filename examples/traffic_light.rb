class TrafficLight
  
  extend SimpleStateMachine
  
  def initialize
    set_initial_state(:green)
  end

  # state machine events
  def change_state
    puts "#{@state} => #{@next_state}"
  end

  event :change_state, :green  => :orange,
                       :orange => :red,
                       :red    => :green
end