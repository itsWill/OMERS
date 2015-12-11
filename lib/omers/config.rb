require 'omers/http_handler'

module OMERS
  module Config
    DEFAULT = {
      Handler:     HTTPHandler.new,
      WebRoot:         "./public/",
      IndexFile:       "index.html",
      HttpVersion:     "1.1",
      ChunkSize:        4 * 1024,
      RequestTimeout:   30,
      Port:             4481,
      MaxURILength:     2083
    }

    RACK = DEFAULT.dup.update(
      Handler: nil# RackHandler.new(app) user msut provide this
    )
  end
end
