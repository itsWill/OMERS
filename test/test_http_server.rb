require_relative '../lib/reactor'
require_relative '../lib/http_server'
require 'minitest/autorun'

class TestHTTPServer < MiniTest::Unit::TestCase
  def test_simple_http_server_works
    server = OMERS::HTTPServer.new

    Thread.new do
      Thread.abort_on_exception
      server.run
    end

    assert_equal "Hello World", `echo GET /anything HTTP/1.1 | nc localhost 4481`.strip
  end
end
