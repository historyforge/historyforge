# frozen_string_literal: true

require "rails_helper"

module People
  RSpec.describe Merge do
    let(:user) { create(:user) }
    let(:source) { create(:person, description: "source text") }
    let(:target) { create(:person, description: "target text") }
    let!(:source_record) { create(:census1910_record, person: source) }
    # Note: target_record is created before merge, so its after_commit callback may run
    # after the merge transaction commits, creating an audit log during the merge
    let!(:target_record) { create(:census1920_record, person: target) }
    let(:source_name) { @source_name }

    before do
      PaperTrail.request.whodunnit = user
      @source_name = source.names.first.name
    end

    it "merges successfully" do
      described_class.run(source:, target:)
      expect(source).to be_destroyed
      expect(target.names.map(&:name)).to include(source_name)
      expect(target.census1910_records).to include(source_record)
      expect(target.census1920_records).to include(target_record)
      expect(target.description).to include("target text")
      expect(target.description).to include("source text")
      
      # Expected audit logs:
      # 1. Connected to 1910 Census Record (from moving source_record from source to target during merge)
      # 2. Merged log (from the merge operation)
      # 3. Name variant added (from add_name_to_person_record callback when census record is connected)
      # 4. Connected to 1920 Census Record (from target_record creation in test setup - after_commit callback
      #    runs after the merge transaction commits, so it appears during merge)
      # The name variant log is legitimate - when a census record is connected, it adds a name variant
      # which should be audited as it's a real change to the person record
      expect(target.audit_logs.pluck(:message)).to include(match(/Merged #\d+/))
      expect(target.audit_logs.pluck(:message)).to include(match(/Connected to 1910 Census Record/))
      expect(target.audit_logs.pluck(:message)).to include(match(/Name variant added/))
      # Note: The 1920 connection log is from test setup, not the merge itself
      expect(target.audit_logs.pluck(:message)).to include(match(/Connected to 1920 Census Record/))
    end

    context "with narratives" do
      let(:source_narrative) do
        narrative = build(:narrative, created_by: user)
        narrative.story = "Source narrative story"
        narrative.sources = "Source narrative sources"
        narrative.save!
        source.reload.narratives << narrative
        narrative
      end
      let(:target_narrative) do
        narrative = build(:narrative, created_by: user)
        narrative.story = "Target narrative story"
        narrative.sources = "Target narrative sources"
        narrative.save!
        target.reload.narratives << narrative
        narrative
      end

      before do
        source_narrative
        target_narrative
        PaperTrail.request.whodunnit = user
        described_class.run(source:, target:)
      end

      it "moves narratives from source to target" do
        expect(target.narratives).to include(source_narrative)
        expect(target.narratives).to include(target_narrative)
        expect(target.narratives.count).to eq(2)
      end

      it "does not create duplicate associations" do
        expect(target.narratives.where(id: source_narrative.id).count).to eq(1)
      end
    end

    context "with audios" do
      let(:source_audio) do
        audio = create(:audio, created_by: user)
        source.reload.audios << audio
        audio
      end
      let(:target_audio) do
        audio = create(:audio, created_by: user)
        target.reload.audios << audio
        audio
      end

      before do
        source_audio
        target_audio
        PaperTrail.request.whodunnit = user
        described_class.run(source:, target:)
      end

      it "moves audios from source to target" do
        expect(target.audios).to include(source_audio)
        expect(target.audios).to include(target_audio)
        expect(target.audios.count).to eq(2)
      end

      it "does not create duplicate associations" do
        expect(target.audios.where(id: source_audio.id).count).to eq(1)
      end
    end

    context "with videos" do
      let(:source_video) do
        video = create(:video, created_by: user)
        source.reload.videos << video
        video
      end
      let(:target_video) do
        video = create(:video, created_by: user)
        target.reload.videos << video
        video
      end

      before do
        source_video
        target_video
        PaperTrail.request.whodunnit = user
        described_class.run(source:, target:)
      end

      it "moves videos from source to target" do
        expect(target.videos).to include(source_video)
        expect(target.videos).to include(target_video)
        expect(target.videos.count).to eq(2)
      end

      it "does not create duplicate associations" do
        expect(target.videos.where(id: source_video.id).count).to eq(1)
      end
    end
  end
end
