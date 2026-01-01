# frozen_string_literal: true

require 'rails_helper'

module Buildings
  RSpec.describe Geocode do
    let(:locality) { create(:locality, latitude: 42.4430, longitude: -76.5000) }
    
    # Stub the geocoding callback before creating buildings to prevent actual API calls
    before do
      allow_any_instance_of(Building).to receive(:do_the_geocode)
    end

    let(:building) { create(:building, locality:, lat: nil, lon: nil) }

    describe '#execute' do
      context 'when in test environment' do
        it 'returns early without geocoding' do
          expect(building).not_to receive(:geocode)
          described_class.run(building:)
        end
      end

      context 'when not in test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(false)
        end

        context 'when geocoding succeeds' do
          context 'when geocoded location is within 50km of locality center' do
            before do
              allow(building).to receive(:geocode) do
                building.lat = 42.4430
                building.lon = -76.5000
                true
              end
              described_class.run(building:)
            end

            it 'keeps the geocoded coordinates' do
              expect(building.lat).to eq(42.4430)
              expect(building.lon).to eq(-76.5000)
            end
          end

          context 'when geocoded location is more than 50km from locality center' do
            before do
              allow(building).to receive(:geocode) do
                # Set geocoded coordinates far away (approximately 100km away)
                building.lat = 42.4430 + 0.9 # ~100km north
                building.lon = -76.5000
                true
              end
              described_class.run(building:)
            end

            it 'replaces coordinates with locality center' do
              expect(building.lat).to eq(locality.latitude)
              expect(building.lon).to eq(locality.longitude)
            end
          end

          context 'when building has no locality' do
            # Since buildings require a locality, we'll test the nil check by stubbing locality to return nil
            before do
              allow(building).to receive(:locality).and_return(nil)
              allow(building).to receive(:geocode) do
                building.lat = 42.4430
                building.lon = -76.5000
                true
              end
              described_class.run(building:)
            end

            it 'keeps the geocoded coordinates' do
              expect(building.lat).to eq(42.4430)
              expect(building.lon).to eq(-76.5000)
            end
          end

          context 'when locality has no coordinates' do
            let(:locality) { create(:locality, latitude: nil, longitude: nil) }

            before do
              allow(building).to receive(:geocode) do
                building.lat = 42.4430
                building.lon = -76.5000
                true
              end
              described_class.run(building:)
            end

            it 'keeps the geocoded coordinates' do
              expect(building.lat).to eq(42.4430)
              expect(building.lon).to eq(-76.5000)
            end
          end

          context 'when geocoding returns no coordinates' do
            before do
              allow(building).to receive(:geocode) do
                building.lat = nil
                building.lon = nil
                true
              end
              described_class.run(building:)
            end

            it 'does not modify coordinates' do
              expect(building.lat).to be_nil
              expect(building.lon).to be_nil
            end
          end
        end

        context 'when geocoding fails with network error' do
          before do
            allow(building).to receive(:geocode).and_raise(Errno::ENETUNREACH)
          end

          it 'handles the error gracefully' do
            expect { described_class.run(building:) }.not_to raise_error
          end
        end
      end
    end
  end
end

