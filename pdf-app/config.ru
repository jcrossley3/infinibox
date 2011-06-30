require 'rubygems'
require 'rack'
require 'pdf_app.rb'

use Rack::ShowExceptions
use Rack::ContentLength

run PdfApp.new
