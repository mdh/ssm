$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ssm'
require 'spec'
require 'spec/autorun'

require 'examples/conversation'
require 'examples/lamp'
require 'examples/traffic_light'
require 'examples/user'

Spec::Runner.configure do |config|
  
end
