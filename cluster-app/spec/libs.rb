require 'java'

$LIB1 = "#{ENV['JBOSS_HOME']}/modules/org/jboss/logging/main"
$LIB2 = "#{ENV['JBOSS_HOME']}/modules/org/infinispan/main/"
$LIB3 = "#{ENV['JBOSS_HOME']}/modules/javax/jms/api/main/"
$LIB4 = "#{ENV['JBOSS_HOME']}/modules/javax/transaction/api/main"
require File.join($LIB1, 'jboss-logging-3.1.0.Beta3.jar')
require File.join($LIB2, 'infinispan-core-5.1.0.BETA2.jar')
require File.join($LIB3, 'jboss-jms-api_1.1_spec-1.0.0.Final.jar')
require File.join($LIB4, 'jboss-transaction-api_1.1_spec-1.0.0.Final.jar')
