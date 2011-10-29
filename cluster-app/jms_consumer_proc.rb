require 'rubygems'
require 'torquebox-messaging'

class JmsConsumerProc < TorqueBox::Messaging::MessageProcessor
  def initialize(options = {})
    @logger = TorqueBox::Logger.new( self.class )
  end

  def on_message(hash)
    @logger.info "received message from server => #{hash[:server_name]}"

    @files = hash[:files]
    if @files
       count = 0
       @files.each do |fn|
         #@logger.info "file => #{fn}"
         count += 1
         break if count > 10
       end
    end
  end
end
