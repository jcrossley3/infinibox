require 'rubygems'
require 'torquebox-messaging'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  def initialize(options = {})
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(data)
    @logger.info "received message #{data.size} bytes"

    # write to disk
  end
end
