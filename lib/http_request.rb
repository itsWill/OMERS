#TODO implement HTTP Error codes

require_relative './stream'

require 'timeout'

module OMERS
  class HTTPRequest

    REQUEST_TIMEOUT = 30
    MAX_URI_LENGTH = 2083

    attr_accessor :request

    def initialize
      @request = {
        method: nil,
        uri: nil,
        http_version: nil
      }
    end

    # tod: implement request timeout
    def read_request_line(stream)
     @request_line = stream.handle_read(MAX_URI_LENGTH)

     if @request_line.bytesize >= MAX_URI_LENGTH
      raise StandardError #HTTP MAX URI ERROR
     end

     raise "EOF Error" unless @request_line

     if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d+\.\d+))?\r?\n/ =~ @request_line
      request[:method] = $1
      request[:uri] = normalize_path($2) unless $2.nil?
      request[:http_version] = $3
     else
      raise "Bad Request"
     end
    end

    private

    # taken from: https://github.com/nahi/webrick/blob/master/lib/webrick/httputils.rb#L62-L72
    def normalize_path(path)
      raise "abnormal path `#{path}'" if path[0] != ?/
      ret = path.dup

      ret.gsub!(%r{/+}o, '/')                    # //      => /
      while ret.sub!(%r'/\.(?:/|\Z)', '/'); end  # /.      => /
      while ret.sub!(%r'/(?!\.\./)[^/]+/\.\.(?:/|\Z)', '/'); end # /foo/.. => /foo

      raise "abnormal path `#{path}'" if %r{/\.\.(/|\Z)} =~ ret
      ret
    end
  end
end