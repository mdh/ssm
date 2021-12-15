# A sample Gemfile
source "http://rubygems.org"

group :test do
  gem "rspec"
  gem "activerecord", git: "https://github.com/rails/rails.git", branch: "main"
  gem "sqlite3", :platform => [:ruby, :mswin, :mingw]
  gem "activerecord-jdbcsqlite3-adapter", :platform => :jruby
end
