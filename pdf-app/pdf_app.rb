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
    @jboss_as = jmx_server[javax.management.ObjectName.new( options[:jmx_as_lookup] )]

    @logger = TorqueBox::Logger.new( self.class )
    
    @local_queue = options[:local_queue]
  end

  def call(env)
    req = Rack::Request.new(env)
    sn = @jboss_as.server_name

    @logger.info "web activated #{self.class.to_s} on node #{sn}"

    if req.path.include? 'hash'
      publish_pdf(true)
    else
      publish_pdf(false)
    end

    [200, {"Content-Type" => "text/plain"}, ["JBossAS 6 ServerName => #{sn}"]]
  end

  def publish_pdf(with_hash_flag)
    fn = File.join('public', 'torquebox-doc.pdf')
    msg = File.open( fn, 'rb').read {|io| io.read }
    
    @logger.info "read #{msg.size} bytes from pdf"
    
    @queue = TorqueBox::Messaging::Queue.new( @local_queue )

    if (with_hash_flag == true)
      @queue.publish( {:msg => msg, :file_name => fn } )
      @logger.info "hash published to #{@local_queue}"
    else
      @queue.publish( msg )
      @logger.info "raw data published to #{@local_queue}"
    end
  end
end
