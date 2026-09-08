# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaDateBehavior do
  [Audio, Video, Narrative, Photograph].each do |model|
    context "with #{model}" do
      def dates_for(attributes)
        record = model.new(attributes)
        record.valid?
        [record.date_start, record.date_end]
      end

      let(:model) { model }

      it 'supports historical year ranges spanning different years' do
        expect(dates_for(date_type: :years, date_year: '1880', date_year_end: '1910'))
          .to eq([Date.new(1880, 1, 1), Date.new(1910, 12, 31)])
      end

      it 'includes the last day of a leap-year month' do
        expect(dates_for(date_type: :months, date_year: '1903', date_month: '1',
                         date_year_end: '1904', date_month_end: '2'))
          .to eq([Date.new(1903, 1, 1), Date.new(1904, 2, 29)])
      end

      it 'supports exact day ranges' do
        expect(dates_for(date_type: :days, date_year: '1900', date_month: '1', date_day: '2',
                         date_year_end: '1901', date_month_end: '3', date_day_end: '4'))
          .to eq([Date.new(1900, 1, 2), Date.new(1901, 3, 4)])
      end

      it 'leaves unspecified dates empty' do
        expect(dates_for(date_type: :years, date_year: '', date_year_end: ''))
          .to eq([nil, nil])
      end
    end
  end
end
