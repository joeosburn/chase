require 'spec_helper'

RSpec.describe Chase::Connection do
  let(:included_class) do
    Class.new do
      include Chase::Connection

      def handle; end
      def send_data(_data); end
      def close_connection_after_writing; end
    end
  end
  let(:server) { double('Server') }
  subject { included_class.new }

  before { subject.server = server }

  describe '#receive_data' do
    context 'invalid request' do
      it 'sends a 400 error response' do
        expect(subject).to receive(:send_data).with(/400 Bad Request/).ordered
        expect(subject).to receive(:close_connection_after_writing).ordered
        subject.receive_data('BAD REQUEST')
      end
    end

    context 'valid request' do
      it 'calls #handle_request on the server' do
        expect(server).to receive(:handle_request)
        subject.receive_data("GET / HTTP/1.1\r\n\r\n\0")
      end

      it 'receives multiple blocks of data' do
        subject.receive_data("GET / HTTP/1.1\r\n")
        subject.receive_data("Content-Type: text/plain\r\n")
        subject.receive_data("Cookie: cookie-content\r\n")

        expect(subject.env['HTTP_REQUEST_METHOD']).to eq('GET')
        expect(subject.env['HTTP_REQUEST_URI']).to eq('/')
        expect(subject.env['HTTP_CONTENT_TYPE']).to eq('text/plain')
        expect(subject.env['HTTP_COOKIE']).to eq('cookie-content')
      end

      describe 'the env object' do
        it 'sets env and header variables' do
          subject.receive_data(<<~eos)
            PATCH https://www.google.com/chase/request?key=value&other=123 HTTP/1.1
            Content-Type: text/plain
            Content-Length: 45
            Cookie: cookie-content
            If-None-Match: *
            Random-Header: Value
            Other: Something

            Some-Post-Content=Value&Some-Other=abc2
          eos

          expect(subject.env['HTTP_REQUEST_METHOD']).to eq('PATCH')
          expect(subject.env['HTTP_REQUEST_URI']).to eq('https://www.google.com/chase/request?key=value&other=123')
          expect(subject.env['HTTP_PROTOCOL']).to eq('https')
          expect(subject.env['HTTP_PATH_INFO']).to eq('/chase/request')
          expect(subject.env['HTTP_QUERY_STRING']).to eq('key=value&other=123')
          expect(subject.env['HTTP_CONTENT_TYPE']).to eq('text/plain')
          expect(subject.env['HTTP_CONTENT_LENGTH']).to eq('45')
          expect(subject.env['HTTP_COOKIE']).to eq('cookie-content')
          expect(subject.env['HTTP_IF_NONE_MATCH']).to eq('*')
          expect(subject.env['HTTP_POST_CONTENT']).to eq("Some-Post-Content=Value&Some-Other=abc2\n")
          expect(subject.env['HTTP_HEADERS']['Random-Header']).to eq('Value')
          expect(subject.env['HTTP_HEADERS']['Other']).to eq('Something')
        end
      end
    end
  end
end
