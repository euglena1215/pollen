RSpec.describe Pollen::Message do
  describe '.new' do
    context 'when called on the base class' do
      it 'raises an error' do
        expect { Pollen::Message.new }.to raise_error(Pollen::Message::AbstractClassError)
      end
    end

    context 'when called on a subclass' do
      let(:test_message) do
        Class.new(Pollen::Message) do
          attribute :foo, :string
          attribute :hoge, :integer
        end
      end

      it 'does not raise an error' do
        expect { test_message.new }.not_to raise_error
      end

      it 'sets the attributes' do
        expect(test_message.new(foo: 'bar').foo).to eq('bar')
        expect(test_message.new(hoge: 1).hoge).to eq(1)
      end
    end
  end

  describe '.topic_id' do
    before do
      test_message_klass = Class.new(Pollen::Message)
      stub_const('TestMessage', test_message_klass)
    end

    it 'returns the topic id' do
      expect(TestMessage.topic_id).to eq('pollen.TestMessage')
    end
  end

  describe '.attributes' do
    let(:test_message) do
      Class.new(Pollen::Message) do
        attribute :foo, :string
      end
    end

    it 'returns a hash of attributes' do
      expect(test_message.attributes).to eq({foo: { type: :string, options: {} }})
    end
  end

  describe '.attribute' do
    let(:test_message) do
      Class.new(Pollen::Message) do
        attribute :foo, :string
      end
    end

    it 'adds an attribute to the attributes hash' do
      expect(test_message.attributes).to eq({ foo: { type: :string, options: {} } })
    end
  end

  describe '#validate!' do
    describe 'type validation' do
      let(:test_message) do
        Class.new(Pollen::Message) do
          attribute :foo, :string
          attribute :bar, :integer
          attribute :baz, :float
          attribute :qux, :boolean
          attribute :quux, :array
          attribute :corge, :hash
        end
      end

      context 'when the type is valid' do
        it 'does not raise an error' do
          expect { test_message.new(foo: 'bar').validate! }.not_to raise_error
          expect { test_message.new(bar: 1).validate! }.not_to raise_error
          expect { test_message.new(baz: 1.0).validate! }.not_to raise_error
          expect { test_message.new(qux: true).validate! }.not_to raise_error
          expect { test_message.new(quux: []).validate! }.not_to raise_error
          expect { test_message.new(corge: {}).validate! }.not_to raise_error
        end
      end

      context 'when the type is invalid' do
        it 'raises an error' do
          expect { test_message.new(foo: 1).validate! }.to raise_error(Pollen::Message::InvalidTypeError)
          expect { test_message.new(bar: 'bar').validate! }.to raise_error(Pollen::Message::InvalidTypeError)
          expect { test_message.new(baz: 'bar').validate! }.to raise_error(Pollen::Message::InvalidTypeError)
          expect { test_message.new(qux: 'bar').validate! }.to raise_error(Pollen::Message::InvalidTypeError)
          expect { test_message.new(quux: 'bar').validate! }.to raise_error(Pollen::Message::InvalidTypeError)
          expect { test_message.new(corge: 'bar').validate! }.to raise_error(Pollen::Message::InvalidTypeError)
        end
      end
    end

    describe 'options validation' do
      describe 'required option' do
        context 'when the required option is true' do
          let(:test_message) do
            Class.new(Pollen::Message) do
              attribute :foo, :string, required: true
            end
          end

          context 'when the attribute is present' do
            it 'does not raise an error' do
              expect { test_message.new(foo: 'bar').validate! }.not_to raise_error
            end
          end

          context 'when the attribute is not present' do
            it 'raises an error' do
              expect { test_message.new.validate! }.to raise_error(Pollen::Message::RequiredError)
            end
          end
        end
      end
    end
  end

  describe '#to_h' do
    let(:test_message) do
      Class.new(Pollen::Message) do
        attribute :foo, :string
        attribute :bar, :integer
        attribute :baz, :float
        attribute :qux, :boolean
        attribute :quux, :array
        attribute :corge, :hash
      end
    end

    it 'returns a hash of attributes' do
      expect(test_message.new(foo: 'bar').to_h).to include({foo: 'bar'})
      expect(test_message.new(bar: 1).to_h).to include({bar: 1})
      expect(test_message.new(baz: 1.0).to_h).to include({baz: 1.0})
      expect(test_message.new(qux: true).to_h).to include({qux: true})
      expect(test_message.new(quux: []).to_h).to include({quux: []})
      expect(test_message.new(corge: {}).to_h).to include({corge: {}})
    end
  end
end
