require_relative 'reactor'
require_relative 'http_request'
require_relative 'http_response'
require_relative 'http_handler'

require 'byebug'
require 'uri'

module OMERS
  class HTTPServer
    include EventsEmitter

    attr_reader :listener, :reactor

    def initialize
      @reactor = OMERS::Reactor.new
      @listener = @reactor.listen '0.0.0.0', 4481
    end

    def setup
      listener.on(:accept) do |client|
        client.on(:data) do |data|
          begin
            req = HTTPRequest.new()
            res = HTTPResponse.new()

            req.parse_request(data)
            res.request_method = req.params[:method]
            HTTPHandler.service(req, res)
            res.send_response(client)
          rescue Exception => ex
            puts "#{ex.message} #{ex.backtrace[0]}"
            raise ex
          ensure
            client.close
          end
        end
        client.on(:error) do |ex|
          client.write "error"
          client.close
        end
      end
    end

    def run
      setup
      reactor.start
    end

    def shutdown
      reactor.shutdown
    end
  end
end