$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'simple_state_machine'
require 'spec'
require 'spec/autorun'

require 'examples/conversation'
require 'examples/lamp'
require 'examples/traffic_light'

Spec::Runner.configure do |config|
  
end
