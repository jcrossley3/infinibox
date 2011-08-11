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
    # search the HornetQ MBean queue_name attribute for 'cluster-app'
    qn = @hornetq.queue_names.find_all {|item| item =~ /cluster-app/ }

    [200, {"Content-Type" => "text/html"}, create_html( qn, find( qn )) ]
  end

  # dump the Queue MBean attributes to an html table
  def create_html( queue_name, m_bean )
    out = []

    out << "<html><head><title>#{queue_name}</title></head><body><h3>#{queue_name}</h3>"
    out << "<table>"

    m_bean.attributes.each {|attr| out << "<tr><td>#{attr}</td>" << "<td>#{m_bean[ attr ]}</td></tr>" }
    
    out << "</table></body></html>"
  end
 
  def find( queue_name )
    # query to search the MBeanServer for the specific Queue MBean 
    query_str = "org.hornetq:module=Core,type=Queue,name=\"jms.queue.#{queue_name}\",*" 

    # use jmx_server.query_names to locate a specific Queue MBean 
    @jmx_server.query_names( query_str ).collect do |name|
      return @jmx_server[ name ]
    end

    nil
  end
end
