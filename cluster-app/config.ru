require 'rubygems'
require 'rack'
require 'cluster_app.rb'

use Rack::ShowExceptions
use Rack::ContentLength

run ClusterApp.new
