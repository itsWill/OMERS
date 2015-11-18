require_relative 'utils'

module OMERS
  class HTTPResponse
    attr_accessor :response

    def initialize()
      @params= {
        status: nil,
        http_version: nil,
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
      "HTTP/#{@response[:http_version]} #{@response[:status]} #{response[:reason_phrase]} #{CRLF}"
    end
  end
end