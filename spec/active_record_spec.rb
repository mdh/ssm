require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
gem 'activerecord', '~> 2.3.5'
require 'active_record'
require 'examples/user'

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
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

describe User do
  
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
 
  describe "and_save" do
    it "persists transitions" do
      user = User.create!(:name => 'name')
      user.invite_and_save.should == true
      User.find(user.id).should be_invited
      User.find(user.id).activation_code.should_not be_nil
    end

    it "raises an error if an invalid state_transition is called" do
      user = User.create!(:name => 'name')
      l = lambda { user.confirm_invitation_and_save 'abc' }
      l.should raise_error(RuntimeError, "You cannot 'confirm_invitation' when state is 'new'")
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

  describe "and_save!" do

    it "persists transitions" do
      user = User.create!(:name => 'name')
      user.invite_and_save!.should == true
      User.find(user.id).should be_invited
      User.find(user.id).activation_code.should_not be_nil
    end

    it "raises an error if an invalid state_transition is called" do
      user = User.create!(:name => 'name')
      l = lambda { user.confirm_invitation_and_save! 'abc' }
      l.should raise_error(RuntimeError, "You cannot 'confirm_invitation' when state is 'new'")
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

end
