require 'rubygems'
require 'torquebox-messaging'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  def initialize(options = {})
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(msg)
    pdf_doc = nil

    if msg.kind_of? Hash
      pdf_doc = msg[:msg]
      fn = File.join('public', 'hash-torquebox-doc.pdf')
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
