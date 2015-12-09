require 'reactor'
require 'http_request'
require 'http_response'
require 'http_handler'
require 'config'

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
            res.send_response(client)
          rescue HTTPStatus::Status => ex
            res.set_error(ex)
            res.send_response(client)
          ensure
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
