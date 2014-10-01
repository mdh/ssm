require 'spec_helper'
require 'logger'

if defined? ActiveRecord
  ActiveRecord::Base.logger = Logger.new "test.log"
  ActiveRecord::Base.establish_connection('adapter' => RUBY_PLATFORM == 'java' ? 'jdbcsqlite3' : 'sqlite3', 'database' => ':memory:')

  def setup_db
    ActiveRecord::Schema.define(:version => 1) do
      create_table :users do |t|
        t.column :name,             :string
        t.column :state,            :string
        t.column :activation_code,  :string
        t.column :created_at,       :datetime
        t.column :updated_at,       :datetime
      end
      create_table :tickets do |t|
        t.column :ssm_state,  :string
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

    after_initialize :after_initialize
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

    it "persists transitions when using send and a symbol" do
      user = User.create!(:name => 'name')
      user.send(:invite_and_save).should == true
      User.find(user.id).should be_invited
      User.find(user.id).activation_code.should_not be_nil
    end

    # TODO needs nesting/grouping, seems to have some duplication

    describe "event_and_save" do
      it "persists transitions" do
        user = User.create!(:name => 'name')
        user.invite_and_save.should == true
        User.find(user.id).should be_invited
        User.find(user.id).activation_code.should_not be_nil
      end

      it "persists transitions when using send and a symbol" do
        user = User.create!(:name => 'name')
        user.send(:invite_and_save).should == true
        User.find(user.id).should be_invited
        User.find(user.id).activation_code.should_not be_nil
      end

      it "raises an error if an invalid state_transition is called" do
        user = User.create!(:name => 'name')
        expect {
          user.confirm_invitation_and_save 'abc'
        }.to raise_error(SimpleStateMachine::IllegalStateTransitionError,
                         "You cannot 'confirm_invitation' when state is 'new'")
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
        Array(user.errors[:activation_code]).should == ['is invalid']
      end

      it "rollsback if an exception is raised" do
        user_class = Class.new(User)
        user_class.instance_eval do
          define_method :invite_without_managed_state do
            User.create!(:name => 'name2') #this shouldn't be persisted
            User.create! #this should raise an error
          end
        end
        user_class.count.should == 0
        user = user_class.create!(:name => 'name')
        expect {
          user.transaction { user.invite_and_save }
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Name can't be blank")
        user_class.count.should == 1
        user_class.first.name.should == 'name'
        user_class.first.should be_new
      end

      it "raises an error if an invalid state_transition is called" do
        user = User.create!(:name => 'name')
        expect {
          user.confirm_invitation_and_save! 'abc'
        }.to raise_error(SimpleStateMachine::IllegalStateTransitionError,
                         "You cannot 'confirm_invitation' when state is 'new'")
      end
    end

    describe "event_and_save!" do

      it "persists transitions" do
        user = User.create!(:name => 'name')
        user.invite_and_save!.should == true
        User.find(user.id).should be_invited
        User.find(user.id).activation_code.should_not be_nil
      end

      it "raises an error if an invalid state_transition is called" do
        user = User.create!(:name => 'name')
        expect {
          user.confirm_invitation_and_save! 'abc'
        }.to raise_error(SimpleStateMachine::IllegalStateTransitionError,
                         "You cannot 'confirm_invitation' when state is 'new'")
      end

      it "raises a RecordInvalid and keeps state if record is invalid" do
        user = User.new
        user.should be_new
        user.should_not be_valid
        expect {
          user.invite_and_save!
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Name can't be blank")
        user.should be_new
      end

      it "raises a RecordInvalid and keeps state if event adds errors" do
        user = User.create!(:name => 'name')
        user.invite_and_save!
        user.should be_invited
        expect {
          user.confirm_invitation_and_save!('x')
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Activation code is invalid")
        user.should be_invited
      end

      it "rollsback if an exception is raised" do
        user_class = Class.new(User)
        user_class.instance_eval do
          define_method :invite_without_managed_state do
            User.create!(:name => 'name2') #this shouldn't be persisted
            User.create! #this should raise an error
          end
        end
        user_class.count.should == 0
        user = user_class.create!(:name => 'name')
        expect {
          user.transaction { user.invite_and_save! }
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Name can't be blank")
        user_class.count.should == 1
        user_class.first.name.should == 'name'
        user_class.first.should be_new
      end

    end

    describe "event" do
      it "persists transitions" do
        user = User.create!(:name => 'name')
        user.invite.should == true
        User.find(user.id).should be_invited
        User.find(user.id).activation_code.should_not be_nil
      end

      it "returns false, keeps state and keeps errors if event adds errors" do
        user = User.create!(:name => 'name')
        user.invite_and_save!
        user.should be_invited
        user.confirm_invitation('x').should == false
        user.should be_invited
        Array(user.errors[:activation_code]).should == ['is invalid']
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
        expect { user.invite! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
        user.should be_new
      end

    end

    describe 'custom state method' do

      it "persists transitions" do
        ticket = Ticket.create!
        ticket.ssm_state.should == 'open'
        ticket.close!.should == true
        ticket.ssm_state.should == 'closed'
      end

      it "persists transitions with !" do
        ticket = Ticket.create!
        ticket.ssm_state.should == 'open'
        ticket.close!
        ticket.ssm_state.should == 'closed'
      end

    end

  end
end
