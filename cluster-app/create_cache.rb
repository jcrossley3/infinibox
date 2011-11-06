require 'rubygems'
require 'yaml'

require 'torquebox'
require 'torquebox-core'
require 'torquebox-cache'              # added per 2.x changes


class CreateCache
  def initialize(opts={})
    @cache_name = opts['cache_name']
    cache # create cache
    @logger = TorqueBox::Logger.new( self.class )
  end

  def start
    @logger.info "starting create cache thread => #{@cache_name}"
    Thread.new { run }
  end

  def stop
     @done = true
  end

  def run
    until @done
       sleep(10)
    end 
  end

  def cache
    @cache ||= TorqueBox::Infinispan::Cache.new( :name => @cache_name, 
                                                 :mode => :replicated,
                                                 :sync => true,
                                                 :transaction_mode => false )
  end
end
