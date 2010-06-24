require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Examples" do
  describe "TrafficLight" do
    it "changes to the next state" do
      tl = TrafficLight.new
      tl.state.should == 'green'
      tl.change_state
      tl.state.should == 'orange'
      tl.change_state
      tl.state.should == 'red'
      tl.change_state
      tl.state.should == 'green'
    end
  end
  
  describe "Lamp" do
    it "changes between :on and :off" do
      lamp = Lamp.new
      lamp.state.should == 'off'
      lamp.push_button1
      lamp.state.should == 'on'
      lamp.push_button2
      lamp.state.should == 'off'
      lamp.push_button2
      lamp.state.should == 'on'
      lamp.push_button1
      lamp.state.should == 'off'
    end
  end
  
  describe "Conversation" do
    it "is :unread by default" do
      conversation = Conversation.new
      conversation.state.should == 'unread'
    end
    
    it "changes to read on view" do
      conversation = Conversation.new
      conversation.view
      conversation.state.should == 'read'
    end

    it "changes to closed on close" do
      conversation = Conversation.new
      conversation.close
      conversation.state.should == 'closed'
    end

    it "changes to closed on close if :read" do
      conversation = Conversation.new
      conversation.view
      conversation.close
      conversation.state.should == 'closed'
    end
  end

  describe User do
    it "should work" do
      user = User.new
      user.state.should == 'new'

      if user.send_activation_code
        user.state.should == 'waiting_for_activation'
      else
        user.log_email_error
        user.state.should == 'send_activation_code_failed'
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

