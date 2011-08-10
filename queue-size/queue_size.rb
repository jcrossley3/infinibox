require 'rubygems'
require 'rack'
require 'jmx'

class QueueSize
  java_import javax.management.ObjectName

  def initialize
    @jmx_server ||= JMX::MBeanServer.new
  end

  def call(env)
    results = []
    
    # search the hornetq QueueNames field for 'cluster-app'
    @hornetq = @jmx_server[ "org.hornetq:module=JMS,type=Server" ]
    qn = @hornetq.queue_names.find_all {|item| item =~ /cluster-app/ }
    results << "<h3>#{qn}</h3>"

    # create query to search the hornetq queue MBeans for the 'cluster-app' MBean
    query_str = "org.hornetq:module=Core,type=Queue,name=\"jms.queue.#{qn}\",*"
    my_queue = find( query_str )

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
