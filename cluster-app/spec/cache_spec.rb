require File.dirname(__FILE__) + '/spec_helper'

# A remote group nested within a local one
describe "cluster-app-rspec" do 

  # Deploy our apps
  deploy <<-END.gsub(/^ {4}/,'')
    application:
      root: #{File.dirname(__FILE__)}/..
      env: 'development'
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
  END

  remote_describe "Use Infinispan" do
    require 'torquebox-core'
    require 'torquebox-cache'
 
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
