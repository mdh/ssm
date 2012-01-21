# A sample Gemfile
source "http://rubygems.org"

gemspec

group :test do
  #gem "rake"
  gem "ZenTest"
  gem "rspec"
  gem "activerecord", "~>=2.3.5"
  gem "sqlite3-ruby"
end
