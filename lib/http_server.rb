require_relative './reactor'
require_relative './http_request'

require 'byebug'
require 'uri'

module OMERS
  class HTTPServer
    include EventsEmitter

    WEB_ROOT = './public'

    CONTENT_TYPE_MAPPING = {
      'html' => 'text/html',
      'txt'  => 'text/plain',
      'png'  => 'image/png',
      'jpg'  => 'image/jpeg'
    }

    DEFAULT_CONTENT_TYPE = 'application/octect-stream'

    def content_type(path)
      ext = File.extname(path).split('.').last
      CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
    end

    def requested_file(request_line)
      request_uri = request_line.split(" ")[1]
      path        = URI.unescape(URI(request_uri).path)

      clean = []

      parts = path.split("/")

      parts.each do |part|
        next if part.empty? || part == '.'

        part == '..' ? clean.pop : clean << part
      end

      File.join(WEB_ROOT, *clean)
    end

    attr_reader :listener, :reactor

    def initialize
      @reactor = OMERS::Reactor.new
      @listener = @reactor.listen '0.0.0.0', 4481
    end

    def setup
      listener.on(:accept) do |client|
        client.on(:data) do |data|

          req = HTTPRequest.new()
          req.parse_request(data)
          path = File.join(WEB_ROOT,req.params[:path])

          if File.exist?(path) && !File.directory?(path)
            File.open(path, "rb") do |file|
              client.write "HTTP/1.1 200OK\r\n" +
                           "Content-Type: #{content_type(file)}\r\n" +
                           "Content-Length: #{file.size}\r\n" +
                           "Connection: close \r\n"

              client.write "\r\n"

              begin
                contents = file.read_nonblock(file.size)
              rescue IO::WaitReadable, EOFError
              end

              client.write(contents)

            end
          else
            message = "File not found \n"

            client.write "HTTP/1.1 404 Not Found\r\n" +
                         "Content-Type: text/plain\r\n" +
                         "Content-Length: 16\r\n" +
                         "Connection: close \r\n"
            client.write "\r\n"
          end
         client.close
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