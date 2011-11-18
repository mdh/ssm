require "rubygems"
require "bundler"
Bundler.require
#Bundler.setup(:test)#, :activerecord)
require 'active_record'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'simple_state_machine'
require 'examples/conversation'
require 'examples/lamp'
require 'examples/traffic_light'
require 'examples/user'

