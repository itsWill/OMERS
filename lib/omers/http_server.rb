require 'omers/reactor'
require 'omers/http_request'
require 'omers/http_response'
require 'omers/http_handler'
require 'omers/config'

require 'uri'

module OMERS
  class HTTPServer
    include EventsEmitter

    attr_reader :listener, :reactor

    def initialize(config = Config::DEFAULT)
      @reactor = Reactor.new
      @config  = config
      @listener = @reactor.listen 'localhost', @config[:Port]
    end

    def setup
      listener.on(:accept) do |client|
        client.on(:data) do |data|
          begin
            req = HTTPRequest.new
            res = HTTPResponse.new

            req.parse_request(data)
            res.request_method = req.params[:method]
            handler = @config[:Handler]
            handler.service(req, res)
          rescue HTTPStatus::Status => ex
            res.set_error(ex)
          ensure
            res.send_response(client)
            client.close
          end
        end
      end
    end

    def run
      setup
      puts "[OMERS] Server is listening on port: #{@config[:Port]}"
      reactor.start
    end

    def shutdown
      reactor.shutdown
    end
  end
end
