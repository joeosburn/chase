require 'eventmachine'

module Chase
  # General server error
  class ServerError < StandardError; end

  # HTTP Server Module
  module Server
    include HttpParser

    def receive_data(data)
      parse_request data
      prepare_response
      handle
    rescue ServerError, HTTP::Parser::Error
      send_error('400 Bad Request')
    end

    def request
      @request ||= Request.new
    end

    def response
      @response ||= Response.new
    end

    def send_error(status_code)
      send_data "HTTP/1.1 #{status_code}\r\nConnection: close\r\nContent-Type: text/plain\r\n"
      close_connection_after_writing
    end

    def parse_request(data)
      http_parser << data
      raise ServerError unless request.env['HTTP_METHOD']
    end

    def prepare_response
      response.on(:flushed) { close_connection_after_writing }
      response.on(:write) { |data| send_data(data) }
    end
  end
end
