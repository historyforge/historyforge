# frozen_string_literal: true

class AdminConstraint
  def matches?(request)
    request.session['hi'] = 'bye'
    request.session.delete 'hi'
    return false unless request.session['warden.user.user.key']
    user = User.find request.session['warden.user.user.key'].first.first
    user&.has_role?('Administrator')
  end
end
