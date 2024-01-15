# frozen_string_literal: true

module OmniAuthTestHelper
  def valid_facebook_login_setup
    return unless Rails.env.test?
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new({
                               provider: 'facebook',
                               uid: '123545',
                               info: {
                                 first_name: 'Gaius',
                                 last_name: 'Baltar',
                                 email: 'test@example.com'
                               },
                               credentials: {
                                 token: '123456',
                                 expires_at: 1.week.from_now
                               },
                               extra: {
                                 raw_info: {
                                   gender: 'male'
                                 }
                               }
                             })
  end
end
