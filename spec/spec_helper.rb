require "rubygems"
require "bundler"
Bundler.require :test
begin
  require 'active_record'
rescue LoadError
  puts "Skipping ActiveRecord specs"
end

ROOT = Pathname(File.expand_path(File.join(File.dirname(__FILE__), '..')))
$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'spec')
$LOAD_PATH << File.join(ROOT, 'examples')

require 'simple_state_machine'
require File.join(ROOT, 'examples', 'conversation.rb')
require File.join(ROOT, 'examples', 'lamp.rb')
require File.join(ROOT, 'examples', 'traffic_light.rb')
require File.join(ROOT, 'examples', 'user.rb') if defined? ActiveRecord

