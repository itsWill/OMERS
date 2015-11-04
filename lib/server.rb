module OMERS
  class Server < Stream
    def handle_read
      begin
        client = io.accept_nonblock
        emit(:accept, Stream.new(client))
      rescue Errno::EAGAIN
      end
    end
  end
end
