require 'timeout'
require 'uri'

require_relative 'http_status'
require_relative 'utils'

module OMERS
  class HTTPRequest
    REQUEST_TIMEOUT = 30
    MAX_URI_LENGTH = 2083

    attr_accessor :params

    def initialize
      @params = {
        method: nil,
        uri: nil,
        http_version: nil,
        headers: {},
        body: nil,
        path: nil
      }
    end

    def parse_request(message)
      split_request(message)
      parse_request_line(@request_line)
      parse_headers(@headers)
    end

    def parse_request_line(request_line)
      if request_line.bytesize >= MAX_URI_LENGTH
        raise HTTPStatus::RequestURITooLarge
      end

       raise HTTPStatus::EOFError unless request_line

      if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d+\.\d+))?\r?\n/ =~ request_line
        params[:method] = $1
        params[:uri] = $2
        params[:path] = parse_uri($2) unless $2.nil?
        params[:http_version] = $3
      else
        raise HTTPStatus::BadRequest
      end
    end

    # based on: https://github.com/nahi/webrick/blob/master/lib/webrick/httputils.rb#L162-L190
    def parse_headers(headers)
      field = nil

      @headers.each do |header|
        case header
        when /^([A-Za-z0-9!\#$%&'*+\-.^_`|~]+):\s*(.*?)\s*\z/om
          field, value = $1, $2
          field.downcase
          params[:headers][field] = [] unless params[:headers].has_key?(field)
          params[:headers][field] << value
        when /^\s+(.*?)\s\z/om
          value = $1
          raise HTTPStatus::BadRequest, "bad header #{header}" if field.nil?
          params[:headers][field].last << " " << value
        else
          raise HTTPStatus::BadRequest, "bad header #{header}"
        end
      end

      params[:headers].each do |key, values|
        values.each do |value|
          value.strip!
          value.gsub!(/\s+/," ")
        end

        params[:headers][key] = values.first if values.size == 1
      end
    end

    def parse_uri(str)
      uri = URI::parse(str)
      path = normalize_path(uri.path)
      params[:path] = path
    end

    private

    def split_request(message)
       message = message.split("\n\n")
       @request_line = message[0].lines.first
       @headers = message[0].lines[1...message[0].size]
       params[:body] = message[1]
    end

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