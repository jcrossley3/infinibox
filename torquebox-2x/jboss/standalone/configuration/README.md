# JBoss AS 7 configuration for clustering HornetQ 

## About the HornetQ configuration ##
### Clustered ###
HornetQ configuration uses UDP-based multicast. It may not work on some Cloud (Iaas) providers

Note that the UDP-based broadcast group IP address and port have been added to the *socket-binding-group*

> 
> &lt;socket-binding name="hornetq-broadcast-group" port="0" multicast-address="231.7.7.7" multicast-port="9876"/>
>

### ASYNCIO Journaling ###
The AIO journal type has two dependencies:

+ the hornetq native C language source.  
+ the kernel libaio libraries

The native HornetQ AIO libraries must be compiled per the HornetQ documentation: <http://hornetq.sourceforge.net/docs/hornetq-2.0.0.GA/user-manual/en/html/libaio.html> "2.0.0. GA"
I found it was necessary to rename the *libHornetQAIO.so* file to *libHornetQAIO64.so*

Update LD_LIBRARY_PATH to include the location of *libHornetQAIO32.so* or *libHornetQAOI64.so*

Alternatively, add *-Djava.library.path=PATH* to *standalone.conf*

## About the XML Configuration Files ##
### standalone-ha.xml ###
This is the default JBoss AS 7 standalone-ha.xml, modified to enable HornetQ clustered functionality.  This would be suitable for a multiple machine configuration.

### standalone-ha-server-01.xml ##
This is JBoss AS 7 standalone-ha.xml configuration suitable for running two instances of the application server in standalone mode on the same host.  For example:

>
> ./standalone.sh -b 192.168.1.65 --server-config standalone-ha-server01.xml
> 
> ./standalone.sh -b 192.168.1.66 --server-config standalone-ha-server02.xml
>
>

