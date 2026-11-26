# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it 'resends a pending invitation and invalidates both replaced and accepted links' do
    inviter = create(:administrator)
    user = described_class.invite!({ email: 'invitee@example.test', login: 'invitee' }, inviter)
    old_token = mailed_token

    expect { user.reload.resend_pending_invitation }.to change { ActionMailer::Base.deliveries.size }.by(1)
    new_token = mailed_token
    expect(described_class.find_by_invitation_token(old_token, true)).to be_nil

    accepted = described_class.accept_invitation!(invitation_token: new_token,
                                                   password: 'new-password', password_confirmation: 'new-password')
    expect(accepted.errors).to be_empty
    expect(accepted.reload).to be_enabled
    expect(accepted.invited_by).to eq(inviter)
    expect(described_class.find_by_invitation_token(new_token, true)).to be_nil
    expect(accepted.resend_pending_invitation).to be false
  end

  it 'invalidates a pending link when its account is deleted' do
    user = described_class.invite!({ email: 'invitee@example.test', login: 'invitee' }, create(:administrator))
    token = mailed_token

    user.destroy!

    expect(described_class.find_by_invitation_token(token, true)).to be_nil
  end

  def mailed_token
    body = ActionMailer::Base.deliveries.last.text_part.body.decoded
    CGI.unescape(body.match(/invitation_token=([^\s]+)/)[1])
  end
end
