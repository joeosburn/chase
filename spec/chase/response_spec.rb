require 'spec_helper'

RSpec.describe Chase::Response do
  describe '#flush' do
    before do
      subject.headers['Content-Type'] = 'text/plain'
      subject.headers['Content-Length'] = 40
      subject.content = 'Some content'
    end

    it 'flushes the response' do
      subject.flush
      expect(subject).to be_flushed
    end

    it 'emits the headers and content' do
      output = ''
      subject.on(:send) { |data| output += data }

      subject.flush

      expect(output).to eq(<<~eos.strip)
        HTTP/1.1 200 OK\r
        Content-Type: text/plain\r
        Content-Length: 40\r
        \r
        Some content
      eos
    end

    context 'has been run' do
      before { subject.flush }

      it 'does not emit content again' do
        output = ''
        subject.on(:send) { |data| output += data }
        
        subject.flush
        expect(output).to eq('')
      end
    end
  end
end
