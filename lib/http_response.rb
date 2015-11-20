require_relative 'utils'

require 'time'

module OMERS
  class HTTPResponse
    attr_accessor :params, :request_method

    def initialize()
      @params= {
        status: nil,
        http_version: HTTP_VERSION,
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
      if request_method == "HEAD"
      else
        resp << params[:body]
      end
    end
  end
end