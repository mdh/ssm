# A sample Gemfile
source "http://rubygems.org"

group :test do
  gem "rspec"
  gem "activerecord", "~>6.0.0"
  gem "sqlite3", :platform => [:ruby, :mswin, :mingw]
  gem "activerecord-jdbcsqlite3-adapter", :platform => :jruby
end
