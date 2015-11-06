require_relative 'events_emitter'
require 'byebug'
require 'timeout'

module OMERS
  class Stream
    include EventsEmitter
    CHUNK_SIZE = 4 * 1024
    REQUEST_TIMEOUT = 30

    attr_reader :io

    def initialize(io)
      @io = io
      @write_buffer = ""
    end

    def handle_read(bytes = CHUNK_SIZE)
      begin
        timeout(REQUEST_TIMEOUT) do
          data = io.read_nonblock(bytes)
          emit(:data, data)
        end
      rescue Timeout::Error
        raise HTTPStatus::RequestTimeout
      rescue IO::WaitReadable
      rescue EOFError, Errno::ECONNRESET
        close if io.closed?
      rescue => ex
        puts "#{ex.class}: #{ex.message}\n\t#{ex.backtrace[0]}"
        emit(:error, ex)
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