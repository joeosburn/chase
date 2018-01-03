require 'eventmachine'

module Chase
  # HTTP Server
  class Server
    attr_reader :ip_address, :port, :handler

    def initialize(ip_address, port, &handler)
      @ip_address = ip_address
      @port = port
      @handler = handler
    end

    def start(&block)
      @em = EventMachine.start_server(ip_address, port, Connection) do |connection|
        connection.server = self
        yield connection if block_given?
      end
    end

    def stop
      EventMachine.stop_server(@em)
    end

    def handle_request(env)
      handler.call(Request.new(env), Response.new(env))
    end
  end
end
