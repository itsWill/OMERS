module OMERS
  class Server < Stream
    def handle_read
      begin
        client = io.accept_nonblock
        emit(:accept, Stream.new(client))
      rescue Errno::EAGAIN
      rescue => ex
       puts "#{ex.class}: #{ex.message}\n\t#{ex.backtrace[0]}"
      end
    end
  end
end
