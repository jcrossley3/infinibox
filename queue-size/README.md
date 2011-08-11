A specific queue's MBean is used to find the
instantaneous values for the following attributes:
 
o Address 
o Name
o Filter
o ID
o Durable
o Paused
o Temporary
o DeadLetterAddress
o ExpiryAddress
o ConsumerCount
o MessageCount
o DeliveringCount
o ScheduledCount
o MessagesAdded

Deploy
------------------------------------------------------------------------
jruby -S rake torquebox:deploy
