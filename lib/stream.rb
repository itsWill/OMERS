require_relative 'events_emitter'

module OMERS
  class Stream
    include EventsEmitter
    CHUNK_SIZE = 8 * 1024

    attr_reader :io

    def initialize(io)
      @io = io
      @write_buffer = ""
    end

    def handle_read
      begin
        data = io.read_nonblock(CHUNK_SIZE)
        emit(:data, data)
      rescue IO::WaitReadable
      rescue EOFError, Errno::ECONNRESET
        close if io.closed?
      end
    end

    def handle_write
      return if @write_buffer.empty?
      write(@write_buffer)
    end

    def write(data)
      begin
        bytes = io.write_nonblock(data)
        @write_buffer = data.slice(bytes, data.size)
      rescue IO::WaitWritable
      end
    end

    def close
      emit(:close)
      io.close
    end

    def to_io
      io
    end
  end
end
