# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::MergeEligibilityCheck do
  subject { result.okay? }

  let(:source) { create(:person, description: 'source text') }
  let(:target) { create(:person, description: 'target text') }
  let(:source_record) { create(:census1910_record, person: source) }
  let(:target_record) { nil }
  let(:result) { described_class.new(source, target).tap(&:perform) }

  before do
    PaperTrail.request.whodunnit = create(:user)
    source_record
    target_record
  end

  describe '#okay?' do
    context 'when census records share the same year' do

      let(:target_record) { create(:census1910_record, person: target) }

      it { is_expected.to be_falsey }
    end

    context 'when there is only one census record per year' do
      let(:target_record) { create(:census1920_record, person: target) }

      it { is_expected.to be_truthy }
    end
  end
end
