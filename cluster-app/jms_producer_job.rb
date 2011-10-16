require 'rubygems'
require 'active_support'
# require 'jmx'
require 'yaml'

require 'torquebox'
require 'torquebox-messaging'
require 'active_support/cache/torque_box_store'

class JmsProducerJob
  java_import javax.management.ObjectName

  def initialize
    @options = YAML::load( File.open( File.join('config', 'cluster-app.yml') ))

    @logger = TorqueBox::Logger.new( self.class )

    @queue = TorqueBox::Messaging::Queue.new( @options[:local_queue] )

    replicated_async_cache # create cache
  end

  def run
    sn = "server-name" # log_jmx_info

    if replicated_async_cache.exist?(:semaphor)
      @logger.info "job is currently on #{replicated_async_cache.read(:semaphor)}"
    else
      replicated_async_cache.write(:semaphor, sn, :expires_in => 30.seconds)

      files = Dir.glob('/projects/torquebox/**/**')
      @logger.info "files size => #{files.size}"

      @queue.publish( {:server_name => sn, :files => files} )
    end
  rescue Exception => ex
    @logger.error "Unexpected exception => #{ex}"
  end

  def replicated_async_cache
    @cache ||= ActiveSupport::Cache::TorqueBoxStore.new(:name => @options[:cache_name], :mode => :replicated, :sync => false)
  end
  
  def jmx_server
    @jmx_server ||= JMX::MBeanServer.new
  end

  def server_name
    jboss_as = jmx_server[ javax.management.ObjectName.new( @options[:jmx_as_lookup]) ]
    jboss_as.server_name
  end
  
  def service_name
    jboss_svc = jmx_server[ javax.management.ObjectName.new( @options[:jmx_svc_lookup]) ] 
    jboss_svc.server_name
  end

  def log_jmx_info
    sn = server_name
    @logger.info "scheduler activated #{self.class.to_s} on node #{sn}"
 
    # TODO: remove use of hard-coded primary node name
    if sn == "node0"
      @logger.info "primary node binding => #{service_name}"
    else
      @logger.info "secondary node #{sn} => binding #{service_name}"
      # wait for primary node to outpace this node
      sleep( rand( 10 ) )
    end

    sn
  end
end
