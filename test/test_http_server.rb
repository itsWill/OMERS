require_relative '../lib/reactor'
require_relative '../lib/http_server'
require_relative '../lib/http_status'


require 'test_helper'
require 'uri'
require 'net/http'
require 'byebug'


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
  end

  def test_server_returns_404_on_non_existant_file
    bad_uri = URI.parse("http://localhost:4481/non_existant.html")
    response = Net::HTTP.get_response(bad_uri)
    assert_equal response.code, "404"
    assert_equal response.message, "Not Found "
    assert_equal response.body, ""
  end

  def test_server_returns_error_on_malformed_request
    response =  `echo GET / HTTP/GET | nc localhost 4481`
    status = response.lines[0]
    status = status.split
    assert_equal status[1], "400"
    assert_equal status[2] + " " + status[3], "Bad Request"
  end
end
