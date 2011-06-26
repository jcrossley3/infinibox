require 'rubygems'
require 'active_support'
require 'jmx'
require 'yaml'

require 'torquebox'
require 'torquebox-messaging'
require 'active_support/cache/torque_box_store'

class JmsProducerJob
  java_import javax.management.ObjectName

  def initialize
    options = YAML::load( File.open( File.join('config', 'cluster-app.yml') ))
    jmx_server ||= JMX::MBeanServer.new

    @logger = TorqueBox::Logger.new( self.class )

    jmx_svc_lookup = options[:jmx_svc_lookup] 
    jmx_as_lookup = options[:jmx_as_lookup]
    qn = options[:local_queue]
    cn = options[:cache_name]
    
    @jboss_svc = jmx_server[javax.management.ObjectName.new( jmx_svc_lookup )]
    @jboss_as = jmx_server[javax.management.ObjectName.new( jmx_as_lookup)]
    @queue = TorqueBox::Messaging::Queue.new( qn )
    @cache = ActiveSupport::Cache::TorqueBoxStore.new(:name => cn, :mode => :replicated, :sync => false)
  end

  def run
    @logger.info "starting #{self.class.to_s} job on node #{@jboss_as.server_name}"

    sn = @jboss_as.server_name
 
    if sn == "node0"
      @logger.info "primary node binding => #{@jboss_svc.server_name}"
    else
      @logger.info "secondary node #{sn} => binding #{@jboss_svc.server_name}"
      # wait for primary node to outpace this node
      sleep( rand( 10 ) )
    end

    if @cache.exist?(:semaphor)
      node = @cache.read(:semaphor)
      @logger.info "job is currently on #{node}"
    else
      @cache.write(:semaphor, sn, :expires_in => 30.seconds)
 
      for idx in 0..4 do
        h = {:server_name => sn, :idx => idx}

        @queue.publish(h)
      end
    end
  rescue Exception => ex
    @logger.error "Unexpected exception => #{ex}"
  end
end
