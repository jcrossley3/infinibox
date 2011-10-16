# JBoss AS 7 configuration for clustering HornetQ 

## About the HornetQ configuration ##
Clustered uses UDP-based multicast and will not work on some Cloud (Iaas) providers

The AIO journal type has a dependency on the hornetq native source.  This must be compiled per the HornetQ documentation.

Also, the -Djava.library.path=PATH might be necessary, where PATH represents the location of the HornetQ libHornetQAOI32.so or libHornetQAIO64.so shared libraries.

### standalone-ha ##
This is the default JBoss AS 7 standalone-ha.xml, modified to enable HornetQ clustered functionality.  This would be suitable for a multiple machine configuration.

### standalone-ha-server-01 ##
This is JBoss AS 7 standalone-ha configuration suitable for running two instances of the application server in standalone mode on the same host.  For example:

> ./standalone.sh -b 192.168.1.65 --server-config standalone-ha-server01.xml
> 
> ./standalone.sh -b 192.168.1.66 --server-config standalone-ha-server02.xml
>
>

