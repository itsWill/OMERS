require_relative '../lib/http_request'
require 'minitest/autorun'
require 'byebug'

class TetsHTTPRequest < MiniTest::Unit::TestCase

  # Mock stream object
  class Stream
    def initialize(response)
      @response = response
    end

    def handle_read(bytes)
      @response
    end
  end

  def setup
    @get_request = "GET /index.html HTTP/1.1\r\n"
    @http_request = OMERS::HTTPRequest.new
  end

  def test_valid_get_request_is_successfully_parsed
    @http_request.read_request_line(Stream.new(@get_request))
    assert_equal "GET", @http_request.request[:method]
    assert_equal "/index.html", @http_request.request[:uri]
    assert_equal "1.1", @http_request.request[:http_version]
  end

  def test_request_larger_than_MAX_URI_LENGTH_raises_exception
    large_request = "a" * OMERS::HTTPRequest::MAX_URI_LENGTH

    assert_raises do
      @http_request.read_request_line( Stream.new(large_request) )
    end
  end

  def test_invalid_request_raises_exception
    bad_request = "GET / HTTP/bad.version\r\n"
    assert_raises do
      @http_request.read_request_line( Strem.new(bad_request) )
    end
  end

  def test_uri_path_is_sanitized_on_request
    unsafe_uri = "GET /../../../../../../../../etc/passwd HTTP/1.1\r\n"
    assert_raises do
      @http_request.read_request_line( Stream.new(unsafe_uri) )
    end
  end
end
