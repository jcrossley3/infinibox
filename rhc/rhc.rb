require 'rubygems'
require 'openssl'
require 'json'
require 'net/http'
require 'net/https'

# code from rhc-common version 0.75.9 
module RHC
  API = '1.1.1'   

  def self.generate_json(data)
    data['api'] = API
    json = JSON.generate(data)
    json
  end

  def self.http_post(http, url, json_data, password)
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({'json_data' => json_data, 'password' => password})

    http = http.new(url.host, url.port)
    http.open_timeout = 60

    if url.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    begin
      response = http.start {|http| http.request(req) }
    rescue Exception => ex
      puts "Exception => #{ex}"
      # End of file reached
    end
  end
end

# runs the code leading to an End of file reached exception as seen
# with 'rhc-user-info -l penumbraposts@yahoo.com -p <mypass> -d
net_http = Net::HTTP

data  = {'rhlogin' => 'penumbraposts@yahoo.com', 'debug' => 'true'}
url   = URI.parse("https://openshift.redhat.com/broker/userinfo")
json  = RHC::generate_json(data)

RHC::http_post( net_http, url, json, 'my_password_here' )

