require 'rubygems'
require 'rack'
require 'yaml'
require 'jmx'

require 'torquebox-messaging'
require 'torquebox'

class PdfApp
  java_import javax.management.ObjectName

  def initialize
    options = YAML::load( File.open( File.join('config', 'pdf-app.yml') ))
    jmx_server ||= JMX::MBeanServer.new

    @logger = TorqueBox::Logger.new( self.class )

    @local_queue = options[:local_queue]

    @jboss_as = jmx_server[javax.management.ObjectName.new( options[:jmx_as_lookup] )]
    @jboss_svc = jmx_server[javax.management.ObjectName.new( options[:jmx_svc_lookup] )]
  end

  def call(env)
    sn = @jboss_as.server_name
    svn = @jboss_svc.server_name

    @logger.info "web activated #{self.class.to_s} on node #{sn}"

    publish_pdf

    [200, {"Content-Type" => "text/plain"}, ["JBossAS 6 ServerName => #{sn}, binding => #{svn}"]]
  end

  def publish_pdf
    f = File.open( File.join('public', 'torquebox-doc.pdf'), 'rb' )
    msg = f.read {|io| io.read }

    @logger.info "read #{msg.size} bytes from pdf"
    @queue = TorqueBox::Messaging::Queue.new( @local_queue )
    @queue.publish( msg )
  end
end
