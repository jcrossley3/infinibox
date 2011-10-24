require 'rubygems'
require 'rack'

require 'torquebox'
require 'jmx_helper'
  
class ClusterApp
  include JmxHelper

  def initialize
    @options = YAML::load( File.open( File.join('config', 'cluster-app.yml') ))

    @logger = TorqueBox::Logger.new( self.class )
  end
  
  def call(env)
    sn = server_name

    @logger.info "web activated #{self.class.to_s} on node #{sn}"

    [200, {"Content-Type" => "text/plain"}, ["JBossAS 7 ServerName => #{sn}"]]
  end
end
