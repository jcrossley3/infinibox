require 'rubygems'
require 'jmx'
require 'java'

module JmxHelper
  java_import javax.management.ObjectName

  def jmx_server
    @jmx_server ||= JMX::MBeanServer.new
  end

  def server_name
    # JMX::MBeans::Org::Jboss::As::Webservices::Config::ServerConfigImpl
    jboss_as = jmx_server[javax.management.ObjectName.new( @options[:jmx_as_lookup] )]
    jboss_as.server_data_dir
  end
end
