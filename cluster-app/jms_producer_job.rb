require 'rubygems'
require 'active_support'
require 'jmx'
require 'torquebox'
require 'torquebox-messaging'
require 'active_support/cache/torque_box_store'

class JmsProducerJob
  def initialize
    @jmx_server ||= JMX::MBeanServer.new

    @logger = TorqueBox::Logger.new( self.class )

    @jboss_svc = @jmx_server[javax.management.ObjectName.new( 'jboss.system:service=ServiceBindingManager')]
    @jboss_as = @jmx_server[javax.management.ObjectName.new( 'jboss.system:type=ServerConfig')]

    @queue = TorqueBox::Messaging::Queue.new('/queues/cluster-app/local')
    @cache = ActiveSupport::Cache::TorqueBoxStore.new(:name => "//localhost/cluster-app", :mode => :replicated, :sync => false)
  end

  def run
    @logger.info "starting #{self.class.to_s} job on node #{@jboss_as.server_name}"

    if @jboss_as.server_name == "node0"
      @logger.info "primary node binding => #{@jboss_svc.server_name}"
    else
      @logger.info "secondary node #{@jboss_as.server_name} => binding #{@jboss_svc.server_name}"
      # wait for primary node to outpace this node
      sleep( rand( 10 ) )
    end

    if @cache.exist?(:semaphor)
      node = @cache.read(:semaphor)
      @logger.info "job is currently on #{node}"
    else
      @cache.write(:semaphor, @jboss_as.server_name, :expires_in => 1.minute)    
 
      for idx in 0..4 do
        h = {:adapter => @jboss_as.server_name, :idx => idx}

        @queue.publish(h)
      end
    end
  end
end
