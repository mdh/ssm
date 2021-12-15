require 'spec_helper'

describe "Examples" do
  describe "TrafficLight" do
    it "changes to the next state" do
      tl = TrafficLight.new
      expect(tl).to be_green
      tl.change_state
      expect(tl).to be_orange
      tl.change_state
      expect(tl).to be_red
      tl.change_state
      expect(tl).to be_green
    end
  end

  describe "Lamp" do
    it "changes between :on and :off" do
      lamp = Lamp.new
      expect(lamp).to be_off
      lamp.push_button1
      expect(lamp).to be_on
      lamp.push_button2
      expect(lamp).to be_off
      lamp.push_button2
      expect(lamp).to be_on
      lamp.push_button1
      expect(lamp).to be_off
    end
  end

  describe "Conversation" do
    it "is :unread by default" do
      conversation = Conversation.new
      expect(conversation).to be_unread
    end

    it "changes to read on view" do
      conversation = Conversation.new
      conversation.view
      expect(conversation).to be_read
    end

    it "changes to closed on close" do
      conversation = Conversation.new
      conversation.close
      expect(conversation).to be_closed
    end

    it "changes to closed on close if :read" do
      conversation = Conversation.new
      conversation.view
      conversation.close
      expect(conversation).to be_closed
    end

  end

end

