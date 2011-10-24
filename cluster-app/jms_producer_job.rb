require 'rubygems'
require 'active_support'
require 'yaml'

require 'torquebox'
require 'torquebox-messaging'
require 'jboss-logging-3.0.1.GA.jar'   # added for 2.x build 552
require 'torquebox-cache'              # added for 2.x build 552
require 'active_support/cache/torque_box_store'

require 'jmx_helper'
class JmsProducerJob
  include JmxHelper

  def initialize
    @options = YAML::load( File.open( File.join('config', 'cluster-app.yml') ))

    @logger = TorqueBox::Logger.new( self.class )

    @queue = TorqueBox::Messaging::Queue.new( @options[:local_queue] )

    replicated_async_cache # create cache
  end

  def run
    sn = log_jmx_info

    if replicated_async_cache.exist?(:semaphor)
      @logger.info "job is currently on #{replicated_async_cache.read(:semaphor)}"
    else
      replicated_async_cache.write(:semaphor, sn, :expires_in => 30.seconds)

      files = Dir.glob('/projects/torquebox/**/**')
      @logger.info "files size => #{files.size}"

      @queue.publish( {:server_name => sn, :files => files}, :encoding => :marshal)
    end
  rescue Exception => ex
    @logger.error "Unexpected exception => #{ex}"
  end

  def replicated_async_cache
    @cache ||= ActiveSupport::Cache::TorqueBoxStore.new(:name => @options[:cache_name], :mode => :replicated, :sync => false)
  end
  
  def log_jmx_info
    sn = server_name
    @logger.info "scheduler activated #{self.class.to_s} on node #{sn}"
 
    # TODO: remove use of hard-coded primary node name
    if sn == "/tools/torquebox/jboss/domain/servers/server-01/data"
      @logger.info "primary node binding => "
    else
      @logger.info "secondary node #{sn} => binding "
      # wait for primary node to outpace this node
      sleep( rand( 10 ) )
    end

    sn
  end
end
