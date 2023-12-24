require 'rails_helper'

RSpec.describe PersonName, type: :model do
  subject { FactoryBot.create(:person).names.first }
  describe '#same_name_as?' do
    context 'when the name is indeed the same' do
      it 'returns true' do
        expect(subject.same_name_as?(subject)).to be_truthy
      end
    end
    context 'when the name is different' do
      let(:other_name) { FactoryBot.create(:person).names.first }

      it 'returns false' do
        expect(subject.same_name_as?(other_name)).to be_falsey
      end
    end
  end
end
