module Chase
  # HTTP Request Class
  class Request
    attr_reader :env

    def initialize(env)
      @env = env
    end
  end
end
