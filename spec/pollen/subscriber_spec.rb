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
end
