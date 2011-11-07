require File.dirname(__FILE__) + '/libs'
require 'rubygems'
require 'torquespec'

TorqueSpec.configure do |config|
  config.drb_port = 7772
  config.knob_root = ".torquespec"
  config.jboss_home = '/tools/torquebox/jboss'
  config.lazy = true
  config.jvm_args = "-Xms64m -Xmx1024m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSClassUnloadingEnabled -Dgem.path=default"
end
