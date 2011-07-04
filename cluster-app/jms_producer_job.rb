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
    @jboss_svc = jmx_server[javax.management.ObjectName.new( options[:jmx_svc_lookup] )]
    @jboss_as = jmx_server[javax.management.ObjectName.new( options[:jmx_as_lookup] )]
    @queue = TorqueBox::Messaging::Queue.new( options[:local_queue] )
    @cache = ActiveSupport::Cache::TorqueBoxStore.new(:name => options[:cache_name], :mode => :replicated, :sync => false)
  end

  def run
    sn = @jboss_as.server_name
    @logger.info "scheduler activated #{self.class.to_s} on node #{sn}"
 
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

      files = Dir.glob('/projects/rhq/**/**')
      @logger.info "files size => #{files.size}"

      h = {:server_name => sn, :files => files}
      @queue.publish(h)
    end
  rescue Exception => ex
    @logger.error "Unexpected exception => #{ex}"
  end
end
