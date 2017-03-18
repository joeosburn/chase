require 'eventmachine'

module Chase
  # General server error
  class ServerError < StandardError; end

  # HTTP Server Module
  module Server
    include HttpParser

    def receive_data(data)
      http_parser << data
    rescue ServerError, HTTP::Parser::Error
      send_error('400 Bad Request')
    end

    def request
      @request ||= prepare_request
    end

    def response
      @response ||= Response.new
    end

    def send_error(status_code)
      send_data "HTTP/1.1 #{status_code}\r\nConnection: close\r\nContent-Type: text/plain\r\n"
      close_connection_after_writing
    end

    def prepare_request
      Request.new.tap do |request|
        request.on(:created) do
          raise ServerError unless request.env['REQUEST_METHOD']
          prepare_response
          handle
        end
      end
    end

    def prepare_response
      response.on(:flushed) { close_connection_after_writing }
      response.on(:write) { |data| send_data(data) }
    end
  end
end
