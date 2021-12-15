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
      expect(User.new).to be_new
    end

    it "persists transitions when using send and a symbol" do
      user = User.create!(:name => 'name')
      expect(user.send(:invite_and_save)).to eq(true)
      expect(User.find(user.id)).to be_invited
      expect(User.find(user.id).activation_code).not_to be_nil
    end

    # TODO needs nesting/grouping, seems to have some duplication

    describe "event_and_save" do
      it "persists transitions" do
        user = User.create!(:name => 'name')
        expect(user.invite_and_save).to eq(true)
        expect(User.find(user.id)).to be_invited
        expect(User.find(user.id).activation_code).not_to be_nil
      end

      it "persists transitions when using send and a symbol" do
        user = User.create!(:name => 'name')
        expect(user.send(:invite_and_save)).to eq(true)
        expect(User.find(user.id)).to be_invited
        expect(User.find(user.id).activation_code).not_to be_nil
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
        expect(user).to be_new
        expect(user).not_to be_valid
        expect(user.invite_and_save).to eq(false)
        expect(user).to be_new
      end

      it "returns false, keeps state and keeps errors if event adds errors" do
        user = User.create!(:name => 'name')
        user.invite_and_save!
        expect(user).to be_invited
        expect(user.confirm_invitation_and_save('x')).to eq(false)
        expect(user).to be_invited
        expect(Array(user.errors[:activation_code])).to eq(['is invalid'])
      end

      it "rollsback if an exception is raised" do
        user_class = Class.new(User)
        user_class.instance_eval do
          define_method :invite_without_managed_state do
            User.create!(:name => 'name2') #this shouldn't be persisted
            User.create! #this should raise an error
          end
        end
        expect(user_class.count).to eq(0)
        user = user_class.create!(:name => 'name')
        expect {
          user.transaction { user.invite_and_save }
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Name can't be blank")
        expect(user_class.count).to eq(1)
        expect(user_class.first.name).to eq('name')
        expect(user_class.first).to be_new
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
        expect(user.invite_and_save!).to eq(true)
        expect(User.find(user.id)).to be_invited
        expect(User.find(user.id).activation_code).not_to be_nil
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
        expect(user).to be_new
        expect(user).not_to be_valid
        expect {
          user.invite_and_save!
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Name can't be blank")
        expect(user).to be_new
      end

      it "raises a RecordInvalid and keeps state if event adds errors" do
        user = User.create!(:name => 'name')
        user.invite_and_save!
        expect(user).to be_invited
        expect {
          user.confirm_invitation_and_save!('x')
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Activation code is invalid")
        expect(user).to be_invited
      end

      it "rollsback if an exception is raised" do
        user_class = Class.new(User)
        user_class.instance_eval do
          define_method :invite_without_managed_state do
            User.create!(:name => 'name2') #this shouldn't be persisted
            User.create! #this should raise an error
          end
        end
        expect(user_class.count).to eq(0)
        user = user_class.create!(:name => 'name')
        expect {
          user.transaction { user.invite_and_save! }
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Name can't be blank")
        expect(user_class.count).to eq(1)
        expect(user_class.first.name).to eq('name')
        expect(user_class.first).to be_new
      end

    end

    describe "event" do
      it "persists transitions" do
        user = User.create!(:name => 'name')
        expect(user.invite).to eq(true)
        expect(User.find(user.id)).to be_invited
        expect(User.find(user.id).activation_code).not_to be_nil
      end

      it "returns false, keeps state and keeps errors if event adds errors" do
        user = User.create!(:name => 'name')
        user.invite_and_save!
        expect(user).to be_invited
        expect(user.confirm_invitation('x')).to eq(false)
        expect(user).to be_invited
        expect(Array(user.errors[:activation_code])).to eq(['is invalid'])
      end

    end

    describe "event!" do

      it "persists transitions" do
        user = User.create!(:name => 'name')
        expect(user.invite!).to eq(true)
        expect(User.find(user.id)).to be_invited
        expect(User.find(user.id).activation_code).not_to be_nil
      end

      it "raises a RecordInvalid and keeps state if record is invalid" do
        user = User.new
        expect(user).to be_new
        expect(user).not_to be_valid
        expect { user.invite! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
        expect(user).to be_new
      end

    end

    describe 'custom state method' do

      it "persists transitions" do
        ticket = Ticket.create!
        expect(ticket.ssm_state).to eq('open')
        expect(ticket.close!).to eq(true)
        expect(ticket.ssm_state).to eq('closed')
      end

      it "persists transitions with !" do
        ticket = Ticket.create!
        expect(ticket.ssm_state).to eq('open')
        ticket.close!
        expect(ticket.ssm_state).to eq('closed')
      end

    end

  end
end
