require 'spec_helper'

RSpec.describe Chase::Events do
  let(:example_class) { Class.new { include Chase::Events } }
  subject { example_class.new }
  let(:dummy) { double }

  describe 'emitting events' do
    before { allow(dummy).to receive(:call) }

    it 'calls the block on emit' do
      subject.on(:event) { dummy.call }
      expect(dummy).to receive(:call)
      subject.emit(:event)
    end

    it 'passes arguments to the block' do
      subject.on(:bad_event) { dummy.call(:x, 1) }
      subject.on(:good_event) { |a, b| dummy.call(a, b) }
      expect(dummy).to receive(:call).with(3, :y)
      expect(dummy).to_not receive(:call).with(:x, 1)
      subject.emit(:good_event, 3, :y)
    end

    it 'calls multiple event listeners in the order they were added' do
      subject.on(:event) { dummy.call(1) }
      subject.on(:event) { dummy.call(2) }
      expect(dummy).to receive(:call).with(1).exactly(1).times.ordered
      expect(dummy).to receive(:call).with(2).exactly(1).times.ordered
      subject.emit(:event)
    end
  end
end
