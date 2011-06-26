require 'rubygems'
require 'active_support'
require 'torquebox'
require 'torquebox-messaging'
require 'active_support/cache/torque_box_store'

class JmsProducerJob
  def initialize
    @logger = TorqueBox::Logger.new( self.class )
    @queue = TorqueBox::Messaging::Queue.new('/queues/cluster-app/local')
    @cache = ActiveSupport::Cache::TorqueBoxStore.new(:name => "//localhost/rackapp1", :mode => :replicated, :sync => false)
  end

  def run
    @logger.info "starting #{self.class.to_s} job"

    sleep( rand( 10 ) )
    if @cache.exist?(:semaphor)
      @logger.info "job is currently running"
    else
      @logger.info "updating cache"
      @cache.write(:semaphor, self.class.to_s, :expires_in => 1.minute)    
 
      for idx in 0..4 do
        h = {:adapter => self.class.to_s, :idx => idx}

        @queue.publish(h)
      end
    end
  end
end
