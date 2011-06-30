require 'rubygems'
require 'rack'
require 'yaml'
require 'jmx'

require 'torquebox-messaging'
require 'torquebox'
require 'share.rb'

class PdfApp
  include Properties

  java_import javax.management.ObjectName

  def initialize
    # create attr_readers from yml config
    load( File.join('config', 'pdf-app.yml') )

    jmx_server ||= JMX::MBeanServer.new
    @jboss_as = jmx_server[javax.management.ObjectName.new( @jmx_as_lookup )]

    @logger = TorqueBox::Logger.new( self.class )
  end

  def call(env)
    req = Rack::Request.new(env)
    sn = @jboss_as.server_name

    msg = []
    msg << "JBossAS 6 Rack app running on node => #{sn}\n"

    if req.path.include? 'hash'
      publish_pdf(true)
      msg << "Ruby hash with file => #{@pdf_name} published to queue => #{@local_queue}\n"
    else
      publish_pdf(false)
      msg << "Raw bytes with file => #{@pdf_name} published to queue => #{@local_queue}\n"
    end

    [200, {"Content-Type" => "text/plain"}, msg]
  end

  def publish_pdf(with_hash_flag)
    msg = File.open( @pdf_name, 'rb').read {|io| io.read }
    
    @logger.info "read #{msg.size} bytes from file => #{@pdf_name}"
    
    @queue = TorqueBox::Messaging::Queue.new( @local_queue )

    if (with_hash_flag == true)
      @queue.publish( {:msg => msg, :file_name => @pdf_name } )
      @logger.info "hash published to #{@local_queue}"
    else
      @queue.publish( msg )
      @logger.info "raw data published to #{@local_queue}"
    end
  end
end
