module Chase
  # HTTP Response Class
  class Response
    include Events

    STATUS_CODES = {
      100 => '100 Continue',
      101 => '101 Switching Protocols',
      200 => '200 OK',
      201 => '201 Created',
      202 => '202 Accepted',
      203 => '203 Non-Authoritative Information',
      204 => '204 No Content',
      205 => '205 Reset Content',
      206 => '206 Partial Content',
      300 => '300 Multiple Choices',
      301 => '301 Moved Permanently',
      302 => '302 Found',
      303 => '303 See Other',
      304 => '304 Not Modified',
      305 => '305 Use Proxy',
      307 => '307 Temporary Redirect',
      400 => '400 Bad Request',
      401 => '401 Unauthorized',
      402 => '402 Payment Required',
      403 => '403 Forbidden',
      404 => '404 Not Found',
      405 => '405 Method Not Allowed',
      406 => '406 Not Acceptable',
      407 => '407 Proxy Authentication Required',
      408 => '408 Request Timeout',
      409 => '409 Conflict',
      410 => '410 Gone',
      411 => '411 Length Required',
      412 => '412 Precondition Failed',
      413 => '413 Request Entity Too Large',
      414 => '414 Request-URI Too Long',
      415 => '415 Unsupported Media Type',
      416 => '416 Requested Range Not Satisfiable',
      417 => '417 Expectation Failed',
      500 => '500 Internal Server Error',
      501 => '501 Not Implemented',
      502 => '502 Bad Gateway',
      503 => '503 Service Unavailable',
      504 => '504 Gateway Timeout',
      505 => '505 HTTP Version Not Supported'
    }.freeze

    attr_accessor :status
    attr_reader :content, :headers

    def initialize
      @content = ''
      @headers = {}

      on(:flushed) { @flushed = true }
    end

    def content=(value)
      @content = value.to_s
    end

    def flush
      return if flushed?

      send_headers
      send("\r\n")
      send(content)

      emit(:flushed)
    end

    def flushed?
      @flushed ||= false
    end

    private

    def send(data)
      emit(:send, data)
    end

    def send_headers
      send "HTTP/1.1 #{STATUS_CODES[status] || '200 OK'}\r\n"
      headers.each { |key, value| send("#{key}: #{value}\r\n") }
    end
  end
end
