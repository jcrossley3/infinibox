require 'rubygems'
require 'torquebox-messaging'
require 'share.rb'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  include Properties

  def initialize(options = {})
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(msg)
    pdf_doc = nil

    if msg.kind_of? Hash
      # create attr_readers from key,value pairs
      update!(msg) 

      pdf_doc = @msg
    
      fn = File.join('public', 'hash-torquebox-doc.pdf')
      @logger.info "received #{@file_name} from JMS producer"
    else
      pdf_doc = msg
      fn = File.join('public', 'raw-torquebox-doc.pdf')
    end

    @logger.info "received message => #{pdf_doc.size} bytes"

    f = File.new(fn, 'wb')
    f.write( pdf_doc )
    f.close
  end
end
