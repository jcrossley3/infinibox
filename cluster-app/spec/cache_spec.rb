require File.dirname(__FILE__) + '/spec_helper'

require 'torquebox'
require 'torquebox-core'
require 'torquebox-messaging'
require 'torquebox-cache'

# A remote group nested within a local one
describe "cluster-app-rspec" do 

  # Deploy our apps
  deploy <<-END.gsub(/^ {4}/,'')
    ---
    application:
      root: #{File.dirname(__FILE__)}/..
      env: development
    environment:
      BASEDIR: #{File.dirname(__FILE__)}/..
    ruby:
      version: #{RUBY_VERSION[0,3]}
    web:
      context: /cluster-app
      static: public
    pooling:
      messaging:
        min: 1
        max: 5
    services:
      CreateCache:
        config:
          cache_name: '//localhost/cluster-app'
    queues:
      /queues/cluster-app/local:
        durable: true
    messaging:
      /queues/cluster-app/local:
        JmsConsumerProc:
          concurrency: 1
    jobs:
      publish_notification:
        job:         JmsProducerJob
        cron:        '10 * * * * ?'
        description: Invoke the jms_producer_job.rb every 10 seconds
  END

  remote_describe "Use Infinispan" do
    before :each do
      @cache = TorqueBox::Infinispan::Cache.new( :name => '//localhost/cluster-app' )
    end

    after :each do
      @cache.clear
    end

    it "should accept and return strings" do 
      @cache.put('foo', 'bar').should be_true
      @cache.get('foo').should == 'bar'
    end 
  end
end 
