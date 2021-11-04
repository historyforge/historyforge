module OmniAuthTestHelper
  def valid_facebook_login_setup
    if Rails.env.test?
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:facebook] =
        OmniAuth::AuthHash.new({
                                 provider: 'facebook',
                                 uid: '123545',
                                 info: {
                                   first_name: "Gaius",
                                   last_name:  "Baltar",
                                   email:      "test@example.com"
                                 },
                                 credentials: {
                                   token: "123456",
                                   expires_at: Time.now + 1.week
                                 },
                                 extra: {
                                   raw_info: {
                                     gender: 'male'
                                   }
                                 }
                               })
    end
  end
  def scroll_to(element)
    script = <<-JS
      arguments[0].scrollIntoView(true);
    JS

    Capybara.current_session.driver.browser.execute_script(script, element.native)
  end
end