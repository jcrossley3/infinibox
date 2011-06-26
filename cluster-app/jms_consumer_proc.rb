require 'rubygems'
require 'torquebox-messaging'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  def initialize(options = {})
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(hash)
    @logger.info "received message from server => #{hash[:server_name]} idx => #{hash[:idx]}"
  end
end
