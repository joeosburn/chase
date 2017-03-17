module Chase
  # HTTP Request Class
  class Request
    include Events

    attr_reader :env

    def initialize()
      @env = {}
    end

    def headers
      @headers ||= {}
    end
  end
end
