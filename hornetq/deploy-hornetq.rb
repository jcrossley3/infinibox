require 'rubygems'
require 'fileutils'

home = ENV['TORQUEBOX_HOME']

src = 'build/jars/hornetq-core.jar'
dest0 = home + '/jboss/common/lib/hornetq-core.jar'
FileUtils::copy src, dest0

src = 'build/jars/hornetq-core.jar'
dest1 = home + '/jruby/lib/ruby/gems/1.8/gems/torquebox-messaging-1.0.2-java/lib/hornetq-core-2.1.2.Final.jar'
FileUtils::copy src, dest1

src = 'build/jars/hornetq-core.jar'
dest2 = home + '/jruby/lib/ruby/gems/1.8/gems/torquebox-messaging-container-1.0.2-java/lib/hornetq-core-2.1.2.Final.jar'
FileUtils::copy src, dest2

src2 = 'build/jars/hornetq-core-client.jar'
dest3 = home + '/jboss/client/hornetq-core-client.jar'
FileUtils::copy src2, dest3


src2 = 'build/jars/hornetq-core-client.jar'
dest4 = home + '/jruby/lib/ruby/gems/1.8/gems/torquebox-messaging-1.0.2-java/lib/hornetq-jms-client-2.1.2.Final.jar'
FileUtils::copy src2, dest4

src3 = 'build/jars/hornetq-jms.jar'
dest5 = home + '/jboss/common/lib/hornetq-jms.jar'

