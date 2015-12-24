require 'omers/http_server'
require 'omers/config'

module OMERS
  class RackHandler
    attr_reader :app, :env, :req, :res

    def initialize(app)
      @app = app
    end

    def service(req, res)
      @env = set_env(req)
      @req = req
      @res = res
      set_response(res, app)
    end

    def set_response(res,app)
      status, headers, body = app.call(env)
      res.status = status
      res.params[:headers] = headers
      if body.is_a?(Rack::File)
        res.params[:body] = read_file(body)
      else
        res.params[:body] = body.join
      end
    end

    def read_file(body)
      begin
        file = File.open(body.path)
        file.read_nonblock(Config::DEFAULT[:ChunkSize])
      rescue IO::WaitReadable
      rescue EOFError
        file.close
      end
    end


    def set_env(req)
      {
        'REQUEST_METHOD'    => req.params[:method],
        'SCRIPT_NAME'       => '',
        'PATH_INFO'         => req.params[:path],
        'QUERY_STRING'      => req.params[:path].split('?').last,
        'SERVER_NAME'       => 'localhost',
        'SERVER_PORT'       => Config::DEFAULT[:Port],
        'rack.version'      => Rack.version.split('.'),
        'rack.url_scheme'   => 'http',
        'rack.input'        => String.new(''),
        'rack.errors'       => String.new(''),
        'rack.multithread'  => false,
        'rack.run_once'     => false
      }
    end
  end
end