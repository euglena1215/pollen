RSpec.describe Pollen::Subscriber do
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

  describe '.subscribe!' do
    context 'when called on the base class' do
      before do
        stub_const('TestMessage',
                   Class.new(Pollen::Message) do
                     attribute :foo, :string
                   end
        )
      end
      it 'raises an error' do
        expect {
          described_class.subscribe!(TestMessage.new(foo: 'bar'))
        }.to raise_error(NotImplementedError)
      end
    end

    context 'when called on a subclass' do
      before do
        stub_const('TestMessage',
                   Class.new(Pollen::Message) do
                    attribute :foo, :string
                   end
        )
      end

      let(:test_subscriber) do
        klass = Class.new(Pollen::Subscriber) do
          def self.subscribe!(message)
            message.foo
          end
        end
        klass.use_message(TestMessage)
        klass
      end

      it 'subscribes to the message' do
        expect(test_subscriber.subscribe!(TestMessage.new(foo: 'bar'))).to eq 'bar'
      end
    end
  end

  describe '.listen!' do
    context 'when the message class is not set' do
      before do
        stub_const('TestSubscriber',
                   Class.new(Pollen::Subscriber) do
                     def self.subscribe!(message)
                       # no op
                     end
                   end
        )
      end

      it 'raises an error' do
        expect { TestSubscriber.listen! }.to raise_error(Pollen::Subscriber::NotSetMessageError)
      end
    end

    context 'when the subscriber is already listening' do
      before do
        stub_const('TestMessage',
                   Class.new(Pollen::Message) do
                     attribute :foo, :string
                   end
        )
        stub_const('TestSubscriber',
                   Class.new(Pollen::Subscriber) do
                     def self.subscribe!(message)
                       # no op
                     end
                   end
        )
        TestSubscriber.use_message(TestMessage)
        TestSubscriber.listen!
      end

      it 'does not subscribe again' do
        expect(ActiveSupport::Notifications).not_to receive(:subscribe)
        TestSubscriber.listen!
      end
    end

    context 'when the subscriber is not already listening' do
      before do
        stub_const('TestMessage',
                   Class.new(Pollen::Message) do
                     attribute :foo, :string
                   end
        )
        stub_const('TestSubscriber',
                   Class.new(Pollen::Subscriber) do
                     def self.subscribe!(message)
                       # no op
                     end
                   end
        )
        TestSubscriber.use_message(TestMessage)
      end

      it 'subscribes to the message' do
        expect(ActiveSupport::Notifications).to receive(:subscribe).once
        TestSubscriber.listen!
      end

      it 'sets the is_listening flag' do
        expect {
          TestSubscriber.listen!
        }.to change {
          TestSubscriber.is_listening?
        }.from(false).to(true)
      end

      it 'calls subscribe! when a message is received' do
        allow(TestSubscriber).to receive(:subscribe!) do |message|
          expect(message).to be_a TestMessage
          expect(message.foo).to eq 'bar'
        end
        TestSubscriber.listen!
        ActiveSupport::Notifications.instrument(TestMessage.topic_id, message: TestMessage.new(foo: 'bar').to_h)
      end
    end
  end

  describe '.is_listening?' do
    context 'when the subscriber is listening' do
      before do
        stub_const('TestMessage',
                   Class.new(Pollen::Message) do
                     attribute :foo, :string
                   end
        )
        stub_const('TestSubscriber',
                   Class.new(Pollen::Subscriber) do
                     def self.subscribe!(message)
                       # no op
                     end
                   end
        )
        TestSubscriber.use_message(TestMessage)
        TestSubscriber.listen!
      end

      it 'returns true' do
        expect(TestSubscriber.is_listening?).to be true
      end
    end

    context 'when the subscriber is not listening' do
      before do
        stub_const('TestMessage',
                   Class.new(Pollen::Message) do
                     attribute :foo, :string
                   end
        )
        test_subscriber = Class.new(Pollen::Subscriber) do
          def self.subscribe!(message)
            message.foo
          end
        end
        test_subscriber.use_message(TestMessage)
        # test_subscriber.listen! # not listening
      end

      it 'returns false' do
        expect(described_class.is_listening?).to be false
      end
    end
  end
end
