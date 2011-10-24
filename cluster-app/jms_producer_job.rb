require 'rubygems'
require 'active_support'
require 'yaml'

require 'torquebox'
require 'torquebox-messaging'
require 'jboss-logging-3.0.1.GA.jar'   # added to fix 2.x build 552
require 'torquebox-cache'              # added per 2.x changes
require 'active_support/cache/torque_box_store'

# in domain mode, http://localhost:8090/jboss-osgi/config
# contains a system property: jboss.node.name = server-01
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
    sn = log_server_name

    if replicated_async_cache.exist?(:semaphor)
      @logger.info "job is currently on #{replicated_async_cache.read(:semaphor)}"
    else
      replicated_async_cache.write(:semaphor, sn, :expires_in => 30.seconds)

      files = Dir.glob( @options[:search_path] )
      @logger.info "files size => #{files.size}"

      # marshal_load not found exception see on server.log
      @queue.publish( {:server_name => sn, :files => files}, :encoding => :marshal)
    end
  rescue Exception => ex
    @logger.error "Unexpected exception => #{ex}"
  end

  def replicated_async_cache
    @cache ||= ActiveSupport::Cache::TorqueBoxStore.new(:name => @options[:cache_name], :mode => :replicated, :sync => false)
  end
  
  def log_server_name
    sn = server_name.to_s
    @logger.info "scheduler activated #{self.class.to_s} on #{sn}"
 
    # TODO: remove use of hard-coded primary node name
    if @options[:data_dir] =~ /standalone/
      @logger.info "primary node binding => #{sn}"
    elsif @options[:data_dir] =~ /domain/
      if sn =~ /server-01/
        @logger.info "primary node binding => #{sn}"
      else
        @logger.info "secondary node binding => #{sn}"
        # wait for primary node to outpace this node
        sleep( rand( 10 ) )
      end
    end

    sn
  end
end
