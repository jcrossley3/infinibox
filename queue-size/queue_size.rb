#
# A sample Rack application to illustrate how to use tobias-jmx gem to
# look up the HornetQ JMS server Managed Bean (MBean)
#
# A list of queue names is obtained from the HornetQ MBean
#
# A regex expression is used to find a specific queue 
#
# A specific queue's MBean is used to find the
# instantaneous values for the queue's attributes
#
require 'rubygems'
require 'rack'
require 'jmx'

class QueueSize
  java_import javax.management.ObjectName

  def initialize
    @jmx_server ||= JMX::MBeanServer.new
    @hornetq = @jmx_server[ "org.hornetq:module=JMS,type=Server" ]
  end

  def call(env)
    results = []
    
    # search the hornetq QueueNames field for 'cluster-app'
    qn = @hornetq.queue_names.find_all {|item| item =~ /cluster-app/ }
    results << "<h3>#{qn}</h3>"

    # create query to search the hornetq queue MBeans for the 'cluster-app' MBean
    my_queue = find( "org.hornetq:module=Core,type=Queue,name=\"jms.queue.#{qn}\",*" )

    results |= print_table( my_queue )

    [200, {"Content-Type" => "text/html"}, results ]
  end

  # dump the Queue MBean attributes to an html table
  def print_table( mbean )
    table = []

    table << "<table>"

    mbean.attributes.each do |attr|
      table << "<tr><td>#{attr}</td>"
      table << "<td>#{mbean[ attr ]}</td></tr>"
    end

    table << "</table>"
  end
 
  # use jmx_server.query_names to locate a specific Queue MBean 
  def find( query_str )
    @jmx_server.query_names( query_str ).collect do |name|
      return @jmx_server[ name ]
    end

    nil
  end
end
