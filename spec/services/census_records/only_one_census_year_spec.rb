# frozen_string_literal: true

require 'rails_helper'

module CensusRecords
  RSpec.describe OnlyOneCensusYear do
    context 'when there are no census records saved yet' do
      subject { described_class.call }
      it { is_expected.to be_truthy }
    end

    context 'when there is only one census with records in it' do
      before { FactoryBot.create(:census1910_record) }

      subject { described_class.call }
      it { is_expected.to be_truthy }
    end

    context 'when there are multiple censuses going' do
      before do
        FactoryBot.create(:census1910_record)
        FactoryBot.create(:census1920_record)
      end

      subject { described_class.call }
      it { is_expected.to be_falsey }
    end
  end
end
