require 'socket'

require_relative 'events_emitter'
require_relative './stream'
require_relative './server'

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
      readable, writable, _ = IO.select(streams, streams)

      readable.each { |stream| stream.handle_read  }
      writable.each { |stream| stream.handle_write }
    end
  end
end