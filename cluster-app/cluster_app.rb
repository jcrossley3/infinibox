require 'rubygems'
require 'rack'
require 'torquebox'

class ClusterApp
  def initialize
    @logger = TorqueBox::Logger.new( self.class )
  end

  def call(env)
    @logger.info "called with #{env}"
    [200, {"Content-Type" => "text/plain"}, ["Hello world! #{Time.now}"]]
  end
end
