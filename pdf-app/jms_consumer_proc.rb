require 'rubygems'
require 'torquebox-messaging'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  def initialize(options = {})
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(msg)
    if msg.kind_of? Hash
      pdf_doc = msg[:msg]
      @logger.info "received hash message => #{pdf_doc.size} bytes"
    else
      @logger.info "received raw data => #{msg.size} bytes"
    end
  end
end
