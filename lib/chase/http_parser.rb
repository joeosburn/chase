require 'http-parser-lite'

module Chase
  # Handle parsing of incoming http requests
  module HttpParser
    VALID_METHODS = %w(GET POST PUT DELETE PATCH HEAD OPTIONS).freeze
    MAPPED_HEADERS = { 'cookie' => 'HTTP_COOKIE', 'if-none-match' => 'HTTP_IF_NONE_MATCH',
                       'content-type' => 'HTTP_CONTENT_TYPE', 'content-length' => 'HTTP_CONTENT_LENGTH' }.freeze

    def http_parser
      @parser ||= HTTP::Parser.new.tap do |parser|
        parser.on_message_begin do
          env['HTTP_COOKIE'] = ''
          env['HTTP_POST_CONTENT'] = ''
          env['HTTP_PROTOCOL'] = 'http'
          env['HTTP_PATH_INFO'] = ''
          env['HTTP_QUERY_STRING'] = ''
          env['HTTP_HEADERS'] ||= Hash.new
        end

        parser.on_message_complete do
          raise HTTP::Parser::Error, 'Missing request method' unless env['HTTP_REQUEST_METHOD']
          prepare_response
          handle
        end

        parser.on_url do |url|
          raise HTTP::Parser::Error, 'Invalid request method' unless VALID_METHODS.include?(parser.http_method)

          env['HTTP_REQUEST_METHOD'] = parser.http_method
          env['HTTP_REQUEST_URI'] = url

          matches = url.match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)
          if matches
            env['HTTP_PROTOCOL'] = matches[2]
            env['HTTP_PATH_INFO'] = matches[5]
            env['HTTP_QUERY_STRING'] = matches[7]
          end
        end

        parser.on_header_field { |name| @current_header = name }

        parser.on_header_value do |value|
          if key = MAPPED_HEADERS[@current_header.downcase]
            env[key] = value
          else
            env['HTTP_HEADERS'][@current_header] = value
          end
        end

        parser.on_headers_complete { @current_header = nil }

        parser.on_body { |body| env['HTTP_POST_CONTENT'] = body }
      end
    end
  end
end
