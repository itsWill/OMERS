require_relative '../lib/reactor'
require_relative '../lib/http_server'
require 'minitest/autorun'

class TestHTTPServer < MiniTest::Unit::TestCase
  # start server running in a background thread
  Thread.new { OMERS::HTTPServer.new.run }

  def setup
    @response_200 = "HTTP/1.1 200OK\r\n" +
                    "Content-Type: text/html\r\n" +
                    "Content-Length: 22\r\n" +
                    "Connection: close \r\n" +
                    "\r\n" +
                    "<h1> Hello World </h1>"

    @response_404 = "HTTP/1.1 404 Not Found\r\n" +
                    "Content-Type: text/plain\r\n" +
                    "Content-Length: 16\r\n" +
                    "Connection: close \r\n" +
                    "\r\n"
  end

  def test_server_gets_file_correctly
    assert_equal @response_200, `echo GET /index.html HTTP/1.1 | nc localhost 4481`
  end

  def test_server_returns_404_on_non_existant_file
    assert_equal @response_404, `echo GET /non_existant.html HTTP/1.1 | nc localhost 4481`
  end
end