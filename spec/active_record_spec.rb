require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
gem 'activerecord', '~> 2.3.5'
require 'active_record'
require 'examples/user'

ActiveRecord::Base.logger = Logger.new STDOUT
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do    
    create_table :users do |t|
      t.column :id, :integer
      t.column :name, :string
      t.column :state, :string
      t.column :activation_code, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end
  ActiveRecord::Schema.define(:version => 1) do    
    create_table :tickets do |t|
      t.column :id, :integer
      t.column :ssm_state, :string
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Ticket < ActiveRecord::Base
  extend SimpleStateMachine::ActiveRecord

  state_machine_definition.state_method = :ssm_state
 
  def after_initialize
    self.ssm_state ||= 'open'
  end

  event :close, :open => :closed
end

describe ActiveRecord do
  
  before do
    setup_db
  end
  
  after do
    teardown_db
  end
  
  it "has a default state" do
    User.new.should be_new
  end
  
  # TODO needs nesting/grouping, seems to have some duplication
 
  describe "event_and_save" do
    it "persists transitions" do
      user = User.create!(:name => 'name')
      user.invite_and_save.should == true
      User.find(user.id).should be_invited
      User.find(user.id).activation_code.should_not be_nil
    end

    it "persist transitions even when state is attr_protected" do
      user_class = Class.new(User)
      user_class.instance_eval { attr_protected :state }
      user = user_class.create!(:name => 'name', :state => 'x')
      user.should be_new
      user.invite_and_save
      user.reload.should be_invited
    end

    it "persists transitions when using send and a symbol" do
      user = User.create!(:name => 'name')
      user.send(:invite_and_save).should == true
      User.find(user.id).should be_invited
      User.find(user.id).activation_code.should_not be_nil
    end

    it "raises an error if an invalid state_transition is called" do
      user = User.create!(:name => 'name')
      l = lambda { user.confirm_invitation_and_save 'abc' }
      l.should raise_error(SimpleStateMachine::Error, "You cannot 'confirm_invitation' when state is 'new'")
    end

    it "returns false and keeps state if record is invalid" do
      user = User.new
      user.should be_new
      user.should_not be_valid
      user.invite_and_save.should == false
      user.should be_new
    end

    it "returns false, keeps state and keeps errors if event adds errors" do
      user = User.create!(:name => 'name')
      user.invite_and_save!
      user.should be_invited
      user.confirm_invitation_and_save('x').should == false
      user.should be_invited
      user.errors.entries.should == [['activation_code', 'is invalid']]
    end

  end

  describe "event_and_save!" do

    it "persists transitions" do
      user = User.create!(:name => 'name')
      user.invite_and_save!.should == true
      User.find(user.id).should be_invited
      User.find(user.id).activation_code.should_not be_nil
    end

    it "persist transitions even when state is attr_protected" do
      user_class = Class.new(User)
      user_class.instance_eval { attr_protected :state }
      user = user_class.create!(:name => 'name', :state => 'x')
      user.should be_new
      user.invite_and_save!
      user.reload.should be_invited
    end

    it "raises an error if an invalid state_transition is called" do
      user = User.create!(:name => 'name')
      l = lambda { user.confirm_invitation_and_save! 'abc' }
      l.should raise_error(SimpleStateMachine::Error, "You cannot 'confirm_invitation' when state is 'new'")
    end

    it "raises a RecordInvalid and keeps state if record is invalid" do
      user = User.new
      user.should be_new
      user.should_not be_valid
      l = lambda { user.invite_and_save! }
      l.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
      user.should be_new
    end

    it "raises a RecordInvalid and keeps state if event adds errors" do
      user = User.create!(:name => 'name')
      user.invite_and_save!
      user.should be_invited
      l = lambda { user.confirm_invitation_and_save!('x') }
      l.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Activation code is invalid")
      user.should be_invited
    end

  end

  describe "event!" do

    it "persists transitions" do
      user = User.create!(:name => 'name')
      user.invite!.should == true
      User.find(user.id).should be_invited
      User.find(user.id).activation_code.should_not be_nil
    end

    it "raises a RecordInvalid and keeps state if record is invalid" do
      user = User.new
      user.should be_new
      user.should_not be_valid
      l = lambda { user.invite! }
      l.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
      user.should be_new
    end

  end

  describe 'custom state method' do
    
    it "persists transitions" do
      ticket = Ticket.create!
      ticket.should be_open
      ticket.close.should == true
      ticket.should be_closed
    end

    it "persists transitions with !" do
      ticket = Ticket.create!
      ticket.should be_open
      ticket.close!
      ticket.should be_closed
    end

  end
end
