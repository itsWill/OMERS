module OMERS
  class HTTPResponse
    LF = "\n"
    CRLF = "\r\n"

    attr_accessor :response

    def initialize()
      @response = {
        status: nil,
        http_version: nil,
        reason_phrase: nil,
        headers: {},
        body: nil
      }
    end

    def status=(status)
      @response[:status] = status
      @response[:reason_phrase] = HTTPStatus::reason_phrase(status)
    end

    def status_line
      "HTTP/#{@response[:http_version]} #{@response[:status]} #{response[:reason_phrase]} #{CRLF}"
    end


  end
end