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

    describe '#call' do
      context 'when in test environment' do
        it 'returns early without geocoding' do
          expect(building).not_to receive(:geocode)
          described_class.call(building:)
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
              described_class.call(building:)
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
              described_class.call(building:)
            end

            it 'replaces coordinates with locality center' do
              expect(building.lat).to eq(locality.latitude)
              expect(building.lon).to eq(locality.longitude)
            end
          end

          context 'when building has no locality' do
            # Since buildings require a locality, we'll test the nil check by stubbing locality to return nil
            let(:default_lat) { 42.4418353 }
            let(:default_lon) { -76.4987984 }

            before do
              allow(building).to receive(:locality).and_return(nil)
              allow(AppConfig).to receive(:[]).and_call_original
              allow(AppConfig).to receive(:[]).with(:latitude).and_return(default_lat)
              allow(AppConfig).to receive(:[]).with(:longitude).and_return(default_lon)
            end

            context 'when geocoded location is within 50km of default center' do
              before do
                allow(building).to receive(:geocode) do
                  building.lat = default_lat
                  building.lon = default_lon
                  true
                end
                described_class.call(building:)
              end

              it 'keeps the geocoded coordinates' do
                expect(building.lat).to eq(default_lat)
                expect(building.lon).to eq(default_lon)
              end
            end

            context 'when geocoded location is more than 50km from default center' do
              before do
                allow(building).to receive(:geocode) do
                  # Set geocoded coordinates far away (approximately 100km away)
                  building.lat = default_lat + 0.9 # ~100km north
                  building.lon = default_lon
                  true
                end
                described_class.call(building:)
              end

              it 'replaces coordinates with default center' do
                expect(building.lat).to eq(default_lat)
                expect(building.lon).to eq(default_lon)
              end
            end

            context 'when default center is not configured' do
              before do
                allow(AppConfig).to receive(:[]).with(:latitude).and_return(nil)
                allow(AppConfig).to receive(:[]).with(:longitude).and_return(nil)
                allow(building).to receive(:geocode) do
                  building.lat = 42.4430
                  building.lon = -76.5000
                  true
                end
                described_class.call(building:)
              end

              it 'skips validation and keeps the geocoded coordinates' do
                expect(building.lat).to eq(42.4430)
                expect(building.lon).to eq(-76.5000)
              end
            end
          end

          context 'when locality has no coordinates' do
            let(:locality) { create(:locality, latitude: nil, longitude: nil) }
            let(:default_lat) { 42.4418353 }
            let(:default_lon) { -76.4987984 }

            before do
              allow(AppConfig).to receive(:[]).and_call_original
              allow(AppConfig).to receive(:[]).with(:latitude).and_return(default_lat)
              allow(AppConfig).to receive(:[]).with(:longitude).and_return(default_lon)
            end

            context 'when geocoded location is within 50km of default center' do
              before do
                allow(building).to receive(:geocode) do
                  building.lat = default_lat
                  building.lon = default_lon
                  true
                end
                described_class.call(building:)
              end

              it 'keeps the geocoded coordinates' do
                expect(building.lat).to eq(default_lat)
                expect(building.lon).to eq(default_lon)
              end
            end

            context 'when geocoded location is more than 50km from default center' do
              before do
                allow(building).to receive(:geocode) do
                  # Set geocoded coordinates far away (approximately 100km away)
                  building.lat = default_lat + 0.9 # ~100km north
                  building.lon = default_lon
                  true
                end
                described_class.call(building:)
              end

              it 'replaces coordinates with default center' do
                expect(building.lat).to eq(default_lat)
                expect(building.lon).to eq(default_lon)
              end
            end

            context 'when default center is not configured' do
              before do
                allow(AppConfig).to receive(:[]).with(:latitude).and_return(nil)
                allow(AppConfig).to receive(:[]).with(:longitude).and_return(nil)
                allow(building).to receive(:geocode) do
                  building.lat = 42.4430
                  building.lon = -76.5000
                  true
                end
                described_class.call(building:)
              end

              it 'skips validation and keeps the geocoded coordinates' do
                expect(building.lat).to eq(42.4430)
                expect(building.lon).to eq(-76.5000)
              end
            end
          end

          context 'when geocoding returns no coordinates' do
            before do
              allow(building).to receive(:geocode) do
                building.lat = nil
                building.lon = nil
                true
              end
              described_class.call(building:)
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
            expect { described_class.call(building:) }.not_to raise_error
          end
        end
      end
    end
  end
end

