require 'rubygems'
require 'rack'
require 'yaml'
require 'jmx'

require 'torquebox'

  
class ClusterApp
  java_import javax.management.ObjectName

  def initialize
    @options = YAML::load( File.open( File.join('config', 'cluster-app.yml') ))

    @logger = TorqueBox::Logger.new( self.class )
  end
  
  def jmx_server
    @jmx_server ||= JMX::MBeanServer.new
  end

  def server_name
    jboss_as = jmx_server[javax.management.ObjectName.new( @options[:jmx_as_lookup] )]
    jboss_as.server_name
  end

  def service_name
    jboss_svc = jmx_server[javax.management.ObjectName.new( @options[:jmx_svc_lookup] )]
    jboss_svc.server_name
  end
  
  def call(env)
    sn = server_name
    svn = service_name

    @logger.info "web activated #{self.class.to_s} on node #{sn}"

    [200, {"Content-Type" => "text/plain"}, ["JBossAS 6 ServerName => #{sn}, binding => #{svn}"]]
  end
end
