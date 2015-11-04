require_relative '../lib/http_request'
require_relative '../lib/http_status'
require_relative '../lib/stream'
require 'minitest/autorun'

class TestHTTPRequest < MiniTest::Unit::TestCase

  #mock IO object
  class MockIO
    def read_nonblock(bytes)
      sleep(OMERS::Stream::REQUEST_TIMEOUT + 1)
    end
  end

  def setup
    @get_request = "GET /index.html HTTP/1.1\r\n"
    @http_request = OMERS::HTTPRequest.new
  end

  def test_valid_get_request_is_successfully_parsed
    @http_request.read_request_line(@get_request)
    assert_equal "GET", @http_request.request[:method]
    assert_equal "/index.html", @http_request.request[:uri]
    assert_equal "1.1", @http_request.request[:http_version]
  end

  def test_request_larger_than_MAX_URI_LENGTH_raises_exception
    large_request = "a" * OMERS::HTTPRequest::MAX_URI_LENGTH

    assert_raises(OMERS::HTTPStatus::RequestURITooLarge) do
      @http_request.read_request_line(large_request)
    end
  end

  def test_invalid_request_raises_exception
    bad_request = "GET / HTTP/bad.version\r\n"
    assert_raises(OMERS::HTTPStatus::BadRequest) do
      @http_request.read_request_line(bad_request)
    end
  end

  def test_uri_path_is_sanitized_on_request
    unsafe_uri = "GET /../../../../../../../../etc/passwd HTTP/1.1\r\n"
    assert_raises(OMERS::HTTPStatus::BadRequest) do
      @http_request.read_request_line(unsafe_uri)
    end
  end

  def test_long_request_raises_a_timeout_error
    OMERS::Stream.const_set("REQUEST_TIMEOUT",0.1)
    assert_raises(OMERS::HTTPStatus::RequestTimeout)do
      OMERS::Stream.new(MockIO.new).handle_read
    end
  end
end
