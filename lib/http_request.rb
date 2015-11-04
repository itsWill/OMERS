require 'timeout'
require 'byebug'

module OMERS
  class HTTPRequest
    LF = "\n"

    REQUEST_TIMEOUT = 30
    MAX_URI_LENGTH = 2083

    attr_accessor :request

    def initialize
      @request = {
        method: nil,
        uri: nil,
        http_version: nil,
        headers: {}
      }
    end

    def read_request_line(message)
      @request_line = message.lines.first

      if @request_line.bytesize >= MAX_URI_LENGTH
        raise HTTPStatus::RequestURITooLarge
      end

       raise HTTPStatus::EOFError unless @request_line

      if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d+\.\d+))?\r?\n/ =~ @request_line
        request[:method] = $1
        request[:uri] = normalize_path($2) unless $2.nil?
        request[:http_version] = $3
      else
        raise HTTPStatus::BadRequest
      end
    end

    def read_headers
    end

    private

    # taken from: https://github.com/nahi/webrick/blob/master/lib/webrick/httputils.rb#L62-L72
    def normalize_path(path)
      raise HTTPStatus::BadRequest if path[0] != ?/
      ret = path.dup

      ret.gsub!(%r{/+}o, '/')                    # //      => /
      while ret.sub!(%r'/\.(?:/|\Z)', '/'); end  # /.      => /
      while ret.sub!(%r'/(?!\.\./)[^/]+/\.\.(?:/|\Z)', '/'); end # /foo/.. => /foo

      raise HTTPStatus::BadRequest if %r{/\.\.(/|\Z)} =~ ret
      ret
    end
  end
end