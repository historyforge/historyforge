# frozen_string_literal: true

# Allows us to log in users without having to go through the login form on request specs
# See: https://makandracards.com/makandra/37161-rspec-devise-how-to-sign-in-users-in-request-specs

module DeviseRequestSpecHelpers
  include Warden::Test::Helpers

  def sign_in(resource_or_scope, resource = nil)
    resource ||= resource_or_scope
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    login_as(resource, scope:)
    if RSpec.current_example.metadata[:type] == :feature
      visit root_path
      dismiss_passkey_prompt
    end
  end

  def dismiss_passkey_prompt
    return unless page.has_css?('#passkeyPromptModal.show', wait: 2)

    # Bootstrap ignores hide() while its entrance animation is in progress.
    page.document.synchronize do
      if page.evaluate_script("jQuery('#passkeyPromptModal').data('bs.modal')._isTransitioning")
        raise Capybara::ElementNotFound, 'Passkey prompt is still opening'
      end
    end
    click_button 'Not now'
    expect(page).to have_no_css('#passkeyPromptModal.show')
  end

  def sign_out(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    logout(scope)
  end
end
