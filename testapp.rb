require 'rack'
require 'sinatra'
require 'byebug'

require 'omers'

module Rack
  module Handler
    class HTTPServer
      def self.run(app, options = {})
        ::OMERS::Config::RACK[:Handler] = ::OMERS::RackHandler.new app
        server = ::OMERS::HTTPServer.new(::OMERS::Config::RACK)
        server.run
      end
    end
  end
end
Rack::Handler.register('omers', 'Rack::Handler::HTTPServer')

set :server, :omers
set :logging, false

get '/' do
  'Hello World'
end
