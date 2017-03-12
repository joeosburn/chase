module Chase
  # HTTP Server Module
  module Server
    def receive_data(data)
      send_data ">>>you sent: #{data}"
      close_connection_after_writing
    end
  end
end
