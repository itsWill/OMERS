require_relative '../lib/reactor'
require_relative '../lib/http_server'
require_relative '../lib/http_status'

require 'minitest/autorun'
require 'uri'
require 'net/http'

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
    assert_equal response.code, 200
    assert_equal response.body, "<h1> Hello World </h1>"
  end

  def test_server_returns_404_on_non_existant_file
    assert_equal @response_404, `echo GET /non_existant.html HTTP/1.1 | nc localhost 4481`
  end

  def test_server_returns_error_on_malformed_request
    assert_equal "error", `echo GET / HTTP/GET | nc localhost 4481`
  end
end
