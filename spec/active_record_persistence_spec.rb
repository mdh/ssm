require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
gem 'activerecord', '>= 1.15.4.7794'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :accounts do |t|
      t.column :id, :integer
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

  def after_initialize
    self.state ||= 'pending'
  end

  extend SimpleStateMachine

  def enable
    send_enabled_email
  end
  event :enable,  :pending  => :enabled,
                  :disabled => :enabled
  def disable; end           
  event :disable, :enabled  => :disabled
  
  def send_enabled_email
  end
  
  def state_transition_succeeded_callback(new_state)
    self.state = new_state
    save
  end
end

describe Account do
  
  before do
    setup_db
  end
  
  after do
    teardown_db
  end
  
  it "should have a default state" do
    Account.new.should be_pending
  end
  
  describe "enable" do
    it "should transition from pending to enabled" do
      account = Account.create
      account.enable
      account.reload.should be_enabled
    end
  end

end