require 'timeout'

require 'omers/utils'
require 'omers/events_emitter'
require 'omers/config'

module OMERS
  class Stream
    include EventsEmitter

    attr_reader :io

    def initialize(io)
      @io = io
      @write_buffer = ""
    end

    def handle_read(bytes = Config::DEFAULT[:ChunkSize])
      begin
        timeout(Config::DEFAULT[:RequestTimeout]) do
          data = io.read_nonblock(bytes)
          emit(:data, data)
        end
      rescue Timeout::Error
        raise HTTPStatus::RequestTimeout
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