require_relative './reactor'

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
          client.write "Hello World"
          client.close
        end
      end
    end

    def run
      setup
      reactor.start
    end
  end
end
