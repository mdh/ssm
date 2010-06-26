require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
gem 'activerecord', '>= 1.15.4.7794'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :accounts do |t|
      t.column :id, :integer
      t.column :name, :string
      t.column :state, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Account < ActiveRecord::Base

  validates_presence_of :name

  def after_initialize
    self.state ||= 'pending'
  end

  extend SimpleStateMachine

  def enable
    send_enabled_email
  end
  event :enable,  :pending  => :enabled,
                  :disabled => :enabled
  event :disable, :enabled  => :disabled

  def send_enabled_email
    "email sent"
  end

end

describe Account do
  
  before do
    setup_db
  end
  
  after do
    teardown_db
  end
  
  it "has a default state" do
    Account.new.should be_pending
  end
  
  describe "events" do
    it "can transition from pending to enabled" do
      account = Account.create!(:name => 'name')
      account.enable
      Account.find(account.id).should be_enabled
    end

    it "can transition from pending to enabled with !" do
      account = Account.create!(:name => 'name')
      account.enable!
      Account.find(account.id).should be_enabled
    end

    it "raises an error if an invalid state_transition is called" do
      account = Account.create!(:name => 'name')
      l = lambda { account.disable }
      l.should raise_error(RuntimeError, "You cannot 'disable' when state is 'pending'")
    end

    it "raises a RecordInvalid if called with ! and record is invalid" do
      account = Account.new
      l = lambda { account.enable! }
      l.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
    end

    it "returns the event_method return statement" do
      account = Account.create!(:name => 'name')
      account.enable.should == 'email sent'
      account.disable.should be_nil
    end
  end

end