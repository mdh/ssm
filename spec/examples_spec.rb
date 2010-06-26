require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Examples" do
  describe "TrafficLight" do
    it "changes to the next state" do
      tl = TrafficLight.new
      tl.should be_green
      tl.change_state
      tl.should be_orange
      tl.change_state
      tl.should be_red
      tl.change_state
      tl.should be_green
    end
  end
  
  describe "Lamp" do
    it "changes between :on and :off" do
      lamp = Lamp.new
      lamp.should be_off
      lamp.push_button1
      lamp.should be_on
      lamp.push_button2
      lamp.should be_off
      lamp.push_button2
      lamp.should be_on
      lamp.push_button1
      lamp.should be_off
    end
  end
  
  describe "Conversation" do
    it "is :unread by default" do
      conversation = Conversation.new
      conversation.should be_unread
    end
    
    it "changes to read on view" do
      conversation = Conversation.new
      conversation.view
      conversation.should be_read
    end

    it "changes to closed on close" do
      conversation = Conversation.new
      conversation.close
      conversation.should be_closed
    end

    it "changes to closed on close if :read" do
      conversation = Conversation.new
      conversation.view
      conversation.close
      conversation.should be_closed
    end
  end

  describe User do
    it "should work" do
      user = User.new
      user.state.should == 'new'

      if user.send_activation_code
        user.should be_waiting_for_activation
      else
        user.log_email_error
        user.should be_send_activation_code_failed
      end  

      # # raises error
      # user.reset_password('foo')
      # # user.errors['state'].should == 'cannot reset_password if waiting_for_activation'
      # 
      # user.confirm_activation_code '123'
      # user.state.should == :active
      # 
      # user.reset_password('foo')
      # user.state.should == :active
    end
  end

end

