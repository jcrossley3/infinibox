require 'java'

$LIB1 = '/tools/torquebox/jboss/modules/org/jboss/logging/main'
$LIB2 = '/tools/torquebox/jboss/modules/org/infinispan/main/'
require File.join($LIB1, 'jboss-logging-3.1.0.Beta3.jar')
require File.join($LIB2, 'infinispan-core-5.1.0.BETA2.jar')
