# frozen_string_literal: true

# An administrator explicitly links an existing account or creates an invitation.
# Email delivery happens after this transaction, so failure cannot orphan the link.
class ConnectVolunteerUser
  class Conflict < StandardError; end
  Result = Struct.new(:user, :invited, :already_linked, keyword_init: true)

  def initialize(application, administrator)
    @application = application
    @administrator = administrator
  end

  def call(user_id: nil, login: nil, user_group_id: nil)
    @application.with_lock do
      return Result.new(user: @application.user, invited: false, already_linked: true) if @application.user

      # Serialize invitations from different applications sharing the same email.
      connection = VolunteerApplication.connection
      connection.execute("SELECT pg_advisory_xact_lock(1648, hashtext(#{connection.quote(@application.email)}))")
      matches = User.where('LOWER(email) = ?', @application.email)
      if user_id.present?
        user = matches.lock.find_by(id: user_id)
        raise Conflict, 'That account no longer matches this volunteer’s email. Please review the available accounts.' unless user
      else
        raise Conflict, 'An account already uses this email. Review and link the existing account instead.' if matches.exists?

        user = User.new(full_name: @application.name, email: @application.email, login: login, user_group_id: user_group_id, enabled: false)
        if user_group_id.present? && !UserGroup.exists?(id: user_group_id)
          user.errors.add(:user_group_id, 'is no longer available')
          raise ActiveRecord::RecordInvalid, user
        end
        user.password = Devise.friendly_token(32)
        user.skip_invitation = true
        user.invite!(@administrator, validate: true)
        raise ActiveRecord::RecordInvalid, user unless user.persisted?
      end
      @application.update!(user: user)
      Result.new(user: user, invited: user_id.blank?)
    end
  end
end
