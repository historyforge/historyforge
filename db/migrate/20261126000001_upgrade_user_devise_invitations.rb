# frozen_string_literal: true

require 'digest'

class UpgradeUserDeviseInvitations < ActiveRecord::Migration[8.1]
  LEGACY_FIELDS = %w[invitation_token invitation_created_at invitation_sent_at invitation_accepted_at invited_by_type invited_by_id].freeze

  def up
    create_table :devise_invitations do |t|
      t.string :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.datetime :superseded_at
      t.string :superseded_reason
      t.datetime :revoked_at
      t.datetime :resource_created_at
      t.json :invite_key, null: false, default: {}
      t.string :invite_key_digest, null: false
      t.references :invitable, polymorphic: true
      t.references :invited_by, polymorphic: true
      t.timestamps
    end
    add_index :devise_invitations, :invitation_token, unique: true
    add_index :devise_invitations, %i[invitable_type invite_key_digest], name: 'index_devise_invitations_on_type_and_invite_key'

    users = Class.new(ActiveRecord::Base) { self.table_name = 'users' }
    invitations = Class.new(ActiveRecord::Base) { self.table_name = 'devise_invitations' }
    users.where('invitation_token IS NOT NULL OR invitation_created_at IS NOT NULL OR ' \
                'invitation_sent_at IS NOT NULL OR invitation_accepted_at IS NOT NULL').find_in_batches do |batch|
      invitations.insert_all!(batch.map { |user| invitation_attributes(user) })
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Reconcile invitation writes before reverting to user-backed invitations.'
  end

  private

  def invitation_attributes(user)
    created_at = user.invitation_created_at || user.invitation_sent_at || user.invitation_accepted_at || user.created_at
    email = user.email.to_s.strip.downcase
    user.attributes.slice(*LEGACY_FIELDS).merge(
      invitation_created_at: created_at,
      resource_created_at: created_at,
      revoked_at: (created_at if user.invitation_token.blank? && user.invitation_accepted_at.nil?),
      invite_key: { email: },
      invite_key_digest: Digest::SHA256.hexdigest(['User', 'email', email].join("\0")),
      invitable_type: 'User',
      invitable_id: user.id,
      created_at:,
      updated_at: user.invitation_accepted_at || user.invitation_sent_at || created_at
    ).stringify_keys
  end
end
