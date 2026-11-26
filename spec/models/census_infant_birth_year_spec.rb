# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusRecord do
  describe '#infant_birth_year' do
    {
      1850 => [{ age_months: 7 }, 1849],
      1860 => [{ age_months: 2 }, 1860],
      1870 => [{ birth_month: 9 }, 1869],
      1880 => [{ birth_month: 6, age_months: 0 }, 1880],
      1900 => [{ birth_month: 'unknown', birth_year: 1899 }, 1899],
      1910 => [{ age_months: 4 }, 1909],
      1920 => [{ age_months: 1 }, 1919],
      1930 => [{ age_months: 2 }, 1930],
      1940 => [{ age_months: 7 }, 1939],
      1950 => [{ birth_month: 4 }, 1949],
    }.each do |year, (attributes, expected)|
      it "estimates #{expected} from the #{year} census" do
        record = described_class.for_year(year).new(age: nil, **attributes)

        expect(record.infant_birth_year).to eq(expected)
      end
    end

    it 'ignores invalid infant fields and preserves a known age in years' do
      record = Census1880Record.new(age: 0, birth_month: 13, age_months: 99)
      expect(record.infant_birth_year).to be_nil

      record.assign_attributes(age: 3, birth_month: 6, age_months: 2)
      expect(record.infant_birth_year).to be_nil
    end
  end
end
