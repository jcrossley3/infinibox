require 'rubygems'
require 'rack'
require 'queue_size.rb'

use Rack::ShowExceptions
use Rack::ContentLength

run QueueSize.new
