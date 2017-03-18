require 'http-parser-lite'

module Chase
  # Handle parsing of incoming http requests
  module HttpParser
    VALID_METHODS = %w(GET POST PUT DELETE PATCH HEAD OPTIONS).freeze
    MAPPED_HEADERS = { 'cookie' => 'HTTP_COOKIE', 'if-none-match' => 'IF_NONE_MATCH',
                       'content-type' => 'CONTENT_TYPE', 'content-length' => 'CONTENT_LENGTH' }.freeze

    def http_parser
      @parser ||= HTTP::Parser.new.tap do |parser|
        parser.on_headers_complete { @current_header = nil }

        parser.on_url do |url|
          raise HTTP::Parser::Error, 'Invalid method' unless VALID_METHODS.include?(http_method)

          set_env('REQUEST_METHOD', http_method)
          set_env('REQUEST_URI', url)
          matches = url.match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)
          matches ||= Hash.new('')
          set_env('PROTOCOL', matches[2])
          set_env('PATH_INFO', matches[5])
          set_env('QUERY_STRING', matches[7])
        end

        parser.on_header_field { |name| @current_header = name }

        parser.on_header_value do |value|
          if key = MAPPED_HEADERS[@current_header.downcase]
            set_env(key, value)
          else
            request.headers[@current_header] = value
          end
        end

        parser.on_body { |body| set_env('POST_CONTENT', body) }

        parser.on_message_begin do
          set_env('HTTP_COOKIE', '')
          set_env('POST_CONTENT', '')
        end

        parser.on_message_complete do
          request.emit(:created)
        end
      end
    end

    def http_method
      http_parser.http_method
    end

    def set_env(key, value)
      request.env[key] = value
    end
  end
end
