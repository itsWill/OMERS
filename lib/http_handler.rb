require_relative 'utils'

#based onhttps://github.com/nahi/webrick/blob/master/lib/webrick/httpservlet/filehandler.rb
module OMERS
  class HTTPHandler

    class << self

      def service(req, res)
        method = "http_" + req.params[:method].gsub(/-/,"_")
        if self.respond_to?(method)
          __send__(method, req, res)
        else
          raise HTTPStatus::MethodNotAllowed
        end
      end

      def http_GET(req, res)
        path = File.join(WEB_ROOT, req.params[:path])
        file = find_file(path)

        stat = file.stat
        mtime = stat.mtime

        res.headers['Etag'] = sprintf("%x-%x-%x",stat.ino, stat.size, stat.mtime)

        mtype = Utils.mime_type(path)
        res.headers['Content-Type'] = mtype
        res.headers['Content-Length'] = stat.size

        res.params[:body] = read_file(file)
        res.status = 200;
      end

      def http_HEAD(req, res)
        http_GET(req, res)
      end

      private

      def find_file(path)
        if File.exists?(path) && File.file?(path)
          return File.open(path, "rb")
        elsif File.directory?(path)
          raise HTTPStatus::Forbidden
        else
          raise HTTPStatus::NotFound
        end
      end

      def read_file(file)
        begin
          file.read_nonblock(CHUNK_SIZE)
        rescue IO::WaitReadable
        rescue EOFError
          file.close
        end
      end
    end
  end
end