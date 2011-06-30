require 'rubygems'
require 'digest/sha1'

require 'torquebox-messaging'
require 'share.rb'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  include Properties

  def initialize(options = {})
    load( File.join('config', 'pdf-app.yml') )
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(msg)
    pdf_doc = nil
    fn = nil

    if msg.kind_of? Hash
      # create attr_readers from key,value pairs
      update!(msg) 

      pdf_doc = @msg
    
      fn = @pdf_name + '.hash'
    else
      pdf_doc = msg
      fn = @pdf_name + '.raw'
    end

    @logger.info "received message => #{pdf_doc.size} bytes"

    f = File.new(fn, 'wb')
    f.write( pdf_doc )
    f.close

    if diff(@pdf_name, fn) == false
      @logger.info "files differ"
    else 
      @logger.info "files are the same"
    end
  end

  private 

  def diff(fn1, fn2)
    data = File.open(fn1, 'rb').read {|io| io.read } 
    sha1 = Digest::SHA1.hexdigest data

    data = File.open(fn2, 'rb').read {|io| io.read }
    sha2 = Digest::SHA1.hexdigest data 

    return sha1 == sha2
  end
end
