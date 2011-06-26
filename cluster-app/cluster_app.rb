require 'rubygems'
require 'rack'
require 'yaml'
require 'jmx'

require 'torquebox'

class ClusterApp
  java_import javax.management.ObjectName

  def initialize
    options = YAML::load( File.open( File.join('config', 'cluster-app.yml') ))
    jmx_server ||= JMX::MBeanServer.new

    @logger = TorqueBox::Logger.new( self.class )
    @jboss_as = jmx_server[javax.management.ObjectName.new( options[:jmx_as_lookup] )]
    @jboss_svc = jmx_server[javax.management.ObjectName.new( options[:jmx_svc_lookup] )]
  end

  def call(env)
    sn = @jboss_as.server_name
    svn = @jboss_svc.server_name

    @logger.info "scheduler activated #{self.class.to_s} on node #{sn}"

    [200, {"Content-Type" => "text/plain"}, ["JBossAS 6 ServerName => #{sn}, binding => #{svn}"]]
  end
end
