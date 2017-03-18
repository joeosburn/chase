require 'spec_helper'

RSpec.describe Chase::Server do
  let(:included_class) do
    Class.new do
      include Chase::Server

      def handle; end
      def send_data(_data); end
      def close_connection_after_writing; end
    end
  end
  subject { included_class.new }

  describe '#receive_data' do
    context 'invalid request' do
      it 'sends a 400 error response' do
        expect(subject).to receive(:send_data).with(/400 Bad Request/).ordered
        expect(subject).to receive(:close_connection_after_writing).ordered
        subject.receive_data('BAD REQUEST')
      end
    end

    context 'valid request' do
      it 'calls #handle' do
        expect(subject).to receive(:handle)
        subject.receive_data('GET / HTTP/1.1')
      end

      it 'creates a request object' do
        subject.receive_data('GET / HTTP/1.1')
        expect(subject.request).to be_a(Chase::Request)
      end

      it 'creates a response object' do
        subject.receive_data('GET / HTTP/1.1')
        expect(subject.response).to be_a(Chase::Response)
      end

      describe 'the request object' do
        it 'sets env and header variables' do
          subject.receive_data(<<~eos)
            PATCH https://www.google.com/chase/request?key=value&other=123 HTTP/1.1
            Content-Type: text/plain
            Content-Length: 45
            Cookie: cookie-content
            If-None-Match: *
            Random-Header: Value

            Some-Post-Content=Value&Some-Other=abc2
          eos
          expect(subject.request.env['REQUEST_METHOD']).to eq('PATCH')
          expect(subject.request.env['REQUEST_URI']).to eq('https://www.google.com/chase/request?key=value&other=123')
          expect(subject.request.env['PROTOCOL']).to eq('https')
          expect(subject.request.env['PATH_INFO']).to eq('/chase/request')
          expect(subject.request.env['QUERY_STRING']).to eq('key=value&other=123')
          expect(subject.request.env['CONTENT_TYPE']).to eq('text/plain')
          expect(subject.request.env['CONTENT_LENGTH']).to eq('45')
          expect(subject.request.env['HTTP_COOKIE']).to eq('cookie-content')
          expect(subject.request.env['IF_NONE_MATCH']).to eq('*')
          expect(subject.request.env['POST_CONTENT']).to eq("Some-Post-Content=Value&Some-Other=abc2\n")
          expect(subject.request.headers['Random-Header']).to eq('Value')
        end
      end
    end
  end
end
