RSpec.describe Pollen::Publisher do
  describe '.use_message' do
    let(:test_message) do
      Class.new(Pollen::Message) do
        attribute :foo, :string
      end
    end

    it 'sets the message class' do
      expect {
        described_class.use_message(test_message)
      }.to change {
        described_class.message_klass
      }.from(nil).to(test_message)
    end
  end

  describe '.publish!' do
    context 'when the message class is not set' do
      let(:test_publisher) do
        Class.new(Pollen::Publisher)
      end

      it 'raises an error' do
        expect {
          test_publisher.publish!('foo')
        }.to raise_error(Pollen::Publisher::NotSetMessageError)
      end
    end

    context 'when the message class is set' do
      before do
        stub_const('TestMessage',
                   Class.new(Pollen::Message) do
                    attribute :foo, :string
                   end
        )
      end

      let(:test_publisher) do
        klass = Class.new(Pollen::Publisher)
        klass.use_message(TestMessage)
        klass
      end

      it 'publishes the message' do
        expect(ActiveSupport::Notifications).to receive(:instrument).with('pollen.TestMessage', message: { foo: 'bar' })
        test_publisher.publish!(TestMessage.new(foo: 'bar'))
      end

      it 'receives the message' do
        subscribed_count = 0
        ActiveSupport::Notifications.subscribe(TestMessage.topic_id) do |name, _, _, _, payload|
          expect(name).to eq(TestMessage.topic_id)
          expect(payload[:message][:foo]).to eq('bar')
          subscribed_count += 1
        end
        test_publisher.publish!(TestMessage.new(foo: 'bar'))
        expect(subscribed_count).to eq(1)
      end
    end
  end
end
