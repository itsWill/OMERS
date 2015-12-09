require 'socket'

require 'events_emitter'
require 'stream'
require 'server'


module OMERS
  class Reactor
    include EventsEmitter

    attr_accessor :streams, :socket

    def initialize
      @streams = []
    end

    def listen(host, port)
      @socket = TCPServer.new(host, port)
      server = Server.new(@socket)

      register(server)

      server.on(:accept) do |client|
        register(client)
      end

      server
    end

    def register(stream)
      streams << stream

      stream.on(:close) do
        streams.delete(stream)
      end
    end

    def start
      loop {tick}
    end

    def tick
      begin
        readable, writable, _ = IO.select(streams, streams)

        readable.each { |stream| stream.handle_read  }
        writable.each { |stream| stream.handle_write }
      rescue Errno::EBADF
        # when the server is close on shutdown select will raise Errno::EBADF
      rescue => ex
        raise ex
      end
    end

    def shutdown
      @streams.each do |s|
        s.close
      end
    end
  end
end