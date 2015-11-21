require_relative 'reactor'
require_relative 'http_request'
require_relative 'http_response'
require_relative 'http_handler'
require_relative 'config'

require 'uri'

module OMERS
  class HTTPServer
    include EventsEmitter

    attr_reader :listener, :reactor

    def initialize
      @reactor = Reactor.new
      @config  = Config::DEFAULT
      @listener = @reactor.listen 'localhost', @config[:Port]
    end

    def setup
      listener.on(:accept) do |client|
        client.on(:data) do |data|
          begin
            req = HTTPRequest.new()
            res = HTTPResponse.new()

            req.parse_request(data)
            res.request_method = req.params[:method]
            handler = @config[:Handler]
            handler.service(req, res)
            res.send_response(client)
          rescue HTTPStatus::Status => ex
            res.set_error(ex)
            res.send_response(client)
            puts "#{ex.message} #{ex.backtrace[0]}"
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
