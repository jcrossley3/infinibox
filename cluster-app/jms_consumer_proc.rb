require 'rubygems'
require 'torquebox-messaging'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  def initialize
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(hash)
    @logger.info "received #{hash[:adapter]} idx => #{hash[:idx]}"
  end
end
