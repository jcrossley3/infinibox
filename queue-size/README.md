A sample Rack application that illustrates how to use tobias-jmx gem to 
query the HornetQ JMS server for a list a queue names.

A regex expression is used to find a specific queue within the HornetQ
list of queues, then the Queue's Managed Bean API is used to find the
instantaneous values for the following attributes:
- Address 
- Name
- Filter
- ID
- Durable
- Paused
- Temporary
- DeadLetterAddress
- ExpiryAddress
- ConsumerCount
- MessageCount
- DeliveringCount
- ScheduledCount
- MessagesAdded
