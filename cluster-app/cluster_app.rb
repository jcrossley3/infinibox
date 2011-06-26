require 'rubygems'
require 'rack'
require 'jmx'
require 'torquebox'

class ClusterApp
  java_import javax.management.ObjectName

  def initialize
    @jmx_server ||= JMX::MBeanServer.new

    @logger = TorqueBox::Logger.new( self.class )
  end

  def call(env)
    jboss_as = @jmx_server[javax.management.ObjectName.new( 'jboss.system:type=ServerConfig')]
    jboss_svc = @jmx_server[javax.management.ObjectName.new( 'jboss.system:service=ServiceBindingManager')]

    [200, {"Content-Type" => "text/plain"}, ["JBossAS 6 ServerName => #{jboss_as.server_name}, binding => #{jboss_svc.server_name}"]]
  end
end
