# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::MergeEligibilityCheck do
  let(:source) { create(:person, description: 'source text') }
  let(:target) { create(:person, description: 'target text') }
  let!(:source_record) { create(:census1910_record, person: source) }
  let!(:target_record) { nil }
  subject { described_class.new(source, target) }
  before { PaperTrail.request.whodunnit = create(:user) }
  describe '#okay?' do
    context 'not okay because of census records in the same year' do
      let!(:target_record) { create(:census1910_record, person: target) }
      before { subject.perform }
      it 'says no' do
        expect(subject.okay?).to be_falsey
      end
    end
    context 'is okay because no census records in the same year' do
      let!(:target_record) { create(:census1920_record, person: target) }
      before { subject.perform }
      it 'says no' do
        expect(subject.okay?).to be_truthy
      end
    end
  end
end
