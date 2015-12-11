require 'omers/utils'
require 'omers/config'

require 'time'

module OMERS
  class HTTPResponse
    attr_accessor :params, :request_method

    def initialize()
      @params= {
        status: nil,
        http_version: Config::DEFAULT[:HttpVersion],
        reason_phrase: nil,
        headers: {},
        body: nil
      }
    end

    def status=(status)
      @params[:status] = status
      @params[:reason_phrase] = HTTPStatus::reason_phrase(status)
    end

    def status_line
      "HTTP/#{params[:http_version]} #{params[:status]} #{params[:reason_phrase]} #{CRLF}"
    end

    def send_response(client)
      response = status_line
      setup_headers(response)
      setup_body(response)
      client.write(response)
    end

    def headers
      params[:headers]
    end

    def setup_headers(resp)
      params[:headers]["Date"] = Time.now.httpdate
      params[:headers]["Server"] = "OMERS SERVER TRAINED"
      params[:headers]["Connection"] = "close"

      params[:headers].each do |key, value|
        resp << "#{key}: #{value}" << CRLF
      end
      resp << CRLF
    end

    def setup_body(resp)
      return if request_method == "HEAD" || params[:body] == nil
      resp << params[:body]
    end

    def set_error(err)
      params[:status] = err.code
      params[:reason_phrase] = HTTPStatus.reason_phrase(err.code)
      params[:headers]["Content-Length"] = 0
    end
  end
end