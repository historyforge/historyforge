# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Census1910Record do
  context 'with auto generation of person record' do
    context 'when there are multiple censuses going' do
      let(:record) { build(:census1910_record) }

      before do
        create(:census1920_record)
        record.save && record.review!(create(:user))
      end

      it 'does not generate a person record automatically' do
        expect(record.person).to be_nil
      end
    end

    context 'when it is the very first census record ever' do
      let(:record) { build(:census1910_record) }

      before do
        create(:census1910_record)
        record.save && record.review!(create(:user))
      end

      it 'generates a person record automatically' do
        expect(record.person).not_to be_nil
      end
    end

    context 'when there is only one census going' do
      let(:record) { build(:census1910_record) }

      before { record.save && record.review!(create(:user)) }

      it 'generates a person record automatically' do
        expect(record.person).not_to be_nil
      end
    end
  end
end
