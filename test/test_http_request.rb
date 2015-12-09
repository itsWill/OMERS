require 'test_helper'

class TestHTTPRequest < MiniTest::Test

  #mock IO object
  class MockIO
    def read_nonblock(bytes)
      sleep(OMERS::Config::DEFAULT[:RequestTimeout] + 1)
    end
  end

  def setup
    @get_request = "GET /index.html HTTP/1.1\r\n"
    @http_request = OMERS::HTTPRequest.new
  end

  def test_valid_get_request_is_successfully_parsed
    @http_request.parse_request_line(@get_request)
    assert_equal "GET", @http_request.params[:method]
    assert_equal "/index.html", @http_request.params[:uri]
    assert_equal "1.1", @http_request.params[:http_version]
  end

  def test_request_larger_than_MAX_URI_LENGTH_raises_exception
    large_request = "a" * OMERS::Config::DEFAULT[:MaxURILength]

    assert_raises(OMERS::HTTPStatus::RequestURITooLarge) do
      @http_request.parse_request_line(large_request)
    end
  end

  def test_invalid_request_raises_exception
    bad_request = "GET / HTTP/bad.version\r\n"
    assert_raises(OMERS::HTTPStatus::BadRequest) do
      @http_request.parse_request_line(bad_request)
    end
  end

  def test_uri_path_is_sanitized_on_request
    unsafe_uri = "GET /../../../../../../../../etc/passwd HTTP/1.1\r\n"
    assert_raises(OMERS::HTTPStatus::BadRequest) do
      @http_request.parse_request_line(unsafe_uri)
    end
  end

  def test_long_request_raises_a_timeout_error
    OMERS::Config::DEFAULT[:RequestTimeout] = 0.1
    assert_raises(OMERS::HTTPStatus::RequestTimeout)do
      OMERS::Stream.new(MockIO.new).handle_read
    end
  end

  def test_headers_are_correctly_parsed
    msg = <<-_end_of_message_
      GET /path HTTP/1.1
      Host: test.ruby-lang.org:8080
      Connection: close
      Accept: text/*;q=0.3, text/html;q=0.7, text/html;level=1,
              text/html;level=2;q=0.4, */*;q=0.5
      Accept-Encoding: compress;q=0.5
      Accept-Encoding: gzip;q=1.0, identity; q=0.4, *;q=0
      Accept-Language: en;q=0.5, *; q=0
      Accept-Language: ja
      Content-Type: text/plain
      Content-Length: 7
      X-Empty-Header:

      foobar
    _end_of_message_
    @http_request.parse_request(msg.gsub(/^ {6}/,""))
    result = {
      "Host"=>"test.ruby-lang.org:8080",
      "Connection"=>"close",
      "Accept"=>"text/*;q=0.3, text/html;q=0.7, text/html;level=1," +
                " text/html;level=2;q=0.4, */*;q=0.5",
      "Accept-Encoding"=>["compress;q=0.5", "gzip;q=1.0, identity; q=0.4, *;q=0"],
      "Accept-Language"=>["en;q=0.5, *; q=0", "ja"], "Content-Type"=>"text/plain",
      "Content-Length"=>"7",
      "X-Empty-Header"=>""
    }
    assert_equal @http_request.params[:headers], result
  end
end
