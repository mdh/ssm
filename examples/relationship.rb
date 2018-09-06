# Implementation of the AASM Conversation
#
# class Relationship
#   include AASM
#
#   aasm_column :status
#
#   aasm_initial_state Proc.new { |relationship| relationship.strictly_for_fun? ? :intimate : :dating }
#
#   aasm_state :dating,   :enter => :make_happy,        :exit => :make_depressed
#   aasm_state :intimate, :enter => :make_very_happy,   :exit => :never_speak_again
#   aasm_state :married,  :enter => :give_up_intimacy,  :exit => :buy_exotic_car_and_wear_a_combover
#
#   aasm_event :get_intimate do
#     transitions :to => :intimate, :from => [:dating], :guard => :drunk?
#   end
#
#   aasm_event :get_married do
#     transitions :to => :married, :from => [:dating, :intimate], :guard => :willing_to_give_up_manhood?
#   end
#
#   def strictly_for_fun?; end
#   def drunk?; end
#   def willing_to_give_up_manhood?; end
#   def make_happy; end
#   def make_depressed; end
#   def make_very_happy; end
#   def never_speak_again; end
#   def give_up_intimacy; end
#   def buy_exotic_car_and_wear_a_combover; end
# end

class Relationship
  extend SimpleStateMachine

  def initialize
    self.state = relationship.strictly_for_fun? ? get_intimate : start_dating
  end

  def start_dating
    make_happy
    # make_depressed not called on exit
  end
  event :start_dating, nil => :dating

  def get_intimate
    # exit if drunk?
    make_very_happy
    # never_speak_again not called on exit
  end
  event :get_intimate, :dating => :intimate

  def get_married
    give_up_intimacy
    #exit unless willing_to_give_up_manhood?
    # buy_exotic_car_and_wear_a_combover not called on exit
  end
  event :get_married, :dating   => :married,
                      :intimate => :married

  # extra event added
  def stop_dating
    make_depressed
  end
  event :stop_dating, :dating => nil

  def dump
    never_speak_again
  end
  event :dump, :intimate => :dump

  def divorce
    buy_exotic_car_and_wear_a_combover
  end
  event :divorce, :married => :divorced


  def strictly_for_fun?; end
  def drunk?; end
  def willing_to_give_up_manhood?; end
  def make_happy; end
  def make_depressed; end
  def make_very_happy; end
  def never_speak_again; end
  def give_up_intimacy; end
  def buy_exotic_car_and_wear_a_combover; end
end
