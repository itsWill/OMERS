# based on https://github.com/nahi/webrick/blob/master/lib/webrick/httpstatus.rb
module OMERS
  module HTTPStatus

    class Status < StandardError
      class << self
        attr_reader :code, :reason_phrase
      end

      def code
        self::class::code
      end

      def reason_phrase
        self::class:reason_phrase
      end

      alias to_i code
    end

    class Info < Status; end
    class Success < Status; end
    class Redirect < Status; end
    class Error < Status; end
    class ClientError < Error; end
    class ServerError < Error; end
    class EOFError < StandardError; end

    StatusMessage = {
      100 => 'Continue',
      101 => 'Switching Protocols',
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      203 => 'Non-Authoritative Information',
      204 => 'No Content',
      205 => 'Reset Content',
      206 => 'Partial Content',
      300 => 'Multiple Choices',
      301 => 'Moved Permanently',
      302 => 'Found',
      303 => 'See Other',
      304 => 'Not Modified',
      305 => 'Use Proxy',
      307 => 'Temporary Redirect',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      402 => 'Payment Required',
      403 => 'Forbidden',
      404 => 'Not Found',
      405 => 'Method Not Allowed',
      406 => 'Not Acceptable',
      407 => 'Proxy Authentication Required',
      408 => 'Request Timeout',
      409 => 'Conflict',
      410 => 'Gone',
      411 => 'Length Required',
      412 => 'Precondition Failed',
      413 => 'Request Entity Too Large',
      414 => 'Request-URI Too Large',
      415 => 'Unsupported Media Type',
      416 => 'Request Range Not Satisfiable',
      417 => 'Expectation Failed',
      500 => 'Internal Server Error',
      501 => 'Not Implemented',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      504 => 'Gateway Timeout',
      505 => 'HTTP Version Not Supported'
    }

    CodeToStatus = {}

    # this is cool, write about this
    StatusMessage.each do |code, message|
      status_class_name = message.gsub(/[ \-]/,'')

      case code
      when 100..200; parent = Info
      when 200..300; parent = Success
      when 300..400; parent = Redirect
      when 400..500; parent = ClientError
      when 500..600; parent = ServerError
      end

      status_class = Class.new(parent)
      status_class.instance_variable_set(:@code, code)
      status_class.instance_variable_set(:@reason_phrase, message)
      self.const_set(status_class_name, status_class)
      CodeToStatus[:code] = status_class
    end

    def self.reason_phrase(code)
      StatusMessage[code.to_i]
    end

    def self.[](code)
      CodeToStatus[code]
    end
  end
end