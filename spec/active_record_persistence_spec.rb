require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
gem 'activerecord', '>= 1.15.4.7794'
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
  
  describe "events" do
    it "persists transitions" do
      user = User.create!(:name => 'name')
      user.invite.should == true
      User.find(user.id).should be_invited
    end

    it "persists transitions with !" do
      user = User.create!(:name => 'name')
      user.invite!.should == true
      User.find(user.id).should be_invited
    end

    it "raises an error if an invalid state_transition is called" do
      user = User.create!(:name => 'name')
      l = lambda { user.confirm_invitation 'abc' }
      l.should raise_error(RuntimeError, "You cannot 'confirm_invitation' when state is 'new'")
    end

    it "returns falls if event called and record is invalid" do
      user = User.new
      user.should_not be_valid
      user.invite.should == false
    end

    it "raises a RecordInvalid event if called with ! and record is invalid" do
      user = User.new
      user.should_not be_valid
      l = lambda { user.invite! }
      l.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
    end

    it "returns falls if record is valid but event adds errors" do
      user = User.create!(:name => 'name')
      user.invite!
      user.should be_valid
      r = user.confirm_invitation('x').should == false      
    end

    it "keeps state if record is valid but event adds errors" do
      user = User.create!(:name => 'name')
      user.invite!
      user.should be_valid
      user.confirm_invitation('x')
      user.should be_invited
    end

    it "raises a RecordInvalid if record is valid but event adds errors" # do
     #      user = User.create!(:name => 'name')
     #      user.invite!
     #      user.should be_valid
     #      l = lambda { user.confirm_invitation!('x') }
     #      l.should raise_error(ActiveRecord::RecordInvalid)#, "Validation failed: Name can't be blank")
     #    end

    it "keeps state if record is valid but event adds errors" # do
     #      user = User.create!(:name => 'name')
     #      user.invite!
     #      user.should be_valid
     #      # begin
     #        user.confirm_invitation!('x')
     #      # rescue ActiveRecord::RecordInvalid; end
     #      debugger
     #      user.should be_invited
     #    end

  end

end