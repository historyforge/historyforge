# frozen_string_literal: true

require 'capybara/selenium/driver'
require 'capybara/selenium/driver_specializations/chrome_driver'

module ChromeStorageReset
  def reset!
    @storage_origin = current_url[%r{\Ahttps?://[^/]+}] if @browser
    super
  ensure
    @storage_origin = nil
  end

  private

  def execute_cdp(command, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => error
    # ChromeDriver 158 rejects the wildcard origin used by Capybara 3.40.
    raise unless command == 'Storage.clearDataForOrigin' && params[:origin] == '*' &&
                 error.message.include?('* is not a valid URL')

    super('Network.clearBrowserCookies')
    if @storage_origin && params[:storageTypes].split(',').include?('local_storage')
      super(command, origin: @storage_origin, storageTypes: 'local_storage')
    end
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)
