require_relative '../lib/reactor'
require 'test_helper'

class TestEchoServer < MiniTest::Test
  def test_simple_echo_server_works
    reactor = OMERS::Reactor.new
    server = reactor.listen '0.0.0.0', 4481

    server.on(:accept) do |client|
      client.on(:data) do |data|
        client.write(data)
        client.close
      end
    end

    Thread.new do
      Thread.abort_on_exception = true
      reactor.start
    end

    assert_equal "foo", `echo foo | nc localhost 4481`.strip
    reactor.shutdown
  end
end
