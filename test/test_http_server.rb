require 'test_helper'
require 'uri'
require 'net/http'
require 'socket'

class TestHTTPServer < MiniTest::Test
  def setup
    # start a server running in the background
    @server = OMERS::HTTPServer.new
    @uri = URI.parse("http://localhost:4481")
    Thread.new{ @server.run }
  end

  def teardown
    @server.shutdown
  end

  def test_server_gets_file_correctly
    response = Net::HTTP.get_response(@uri)
    assert_equal response.code, "200"
    assert_equal response.body, "<h1> Hello World </h1>"
    assert_equal "text/html", response.content_type
  end

  def test_server_returns_404_on_non_existant_file
    bad_uri = URI.parse("http://localhost:4481/non_existant.html")
    response = Net::HTTP.get_response(bad_uri)
    assert_equal response.code, "404"
    assert_equal response.message, "Not Found "
    assert_equal response.body, ""
  end

  def test_server_returns_error_on_malformed_request
    client = TCPSocket.new('localhost', 4481)
    client.write "GET / HTTP/GET\r\n"
    response = client.read
    status = response.lines[0]
    status = status.split
    assert_equal "400", status[1]
    assert_equal status[2] + " " + status[3], "Bad Request"
  end
end
