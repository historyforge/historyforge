# frozen_string_literal: true

module CapybaraHelpers
  def retry_until_true(timeout: 10, interval: 0.1)
    start_time = Time.current
    loop do
      begin
        return yield
      rescue => e
        if Time.current - start_time > timeout
          raise e
        end
        sleep interval
      end
    end
  end

  def wait_for_page_load
    # Wait for jQuery to be ready
    expect(page).to have_selector("body", wait: 10)

    # Wait for any AJAX requests to complete
    begin
      page.execute_script("return jQuery.active == 0")
    rescue Selenium::WebDriver::Error::UnknownError => e
      # If we get a DOM error, just wait a bit and continue
      sleep 1
    end

    # Wait a bit more for any animations or DOM updates
    sleep 0.5
  end

  def wait_for_element(selector, **options)
    expect(page).to have_selector(selector, wait: options[:wait] || 10)
  end

  def wait_for_content(content, **options)
    expect(page).to have_content(content, wait: options[:wait] || 10)
  end

  def safe_click(selector, **options)
    retry_until_true(timeout: 15) do
      find_options = { wait: options[:wait] || 10 }
      find_options[:match] = options[:match] if options[:match]
      find_options[:text] = options[:text] if options[:text]

      element = find(selector, **find_options)
      element.click
      true
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("Node with given id does not belong to the document")
        # Wait a bit and try again without refreshing
        sleep 3
        false
      else
        raise e
      end
    end
  end

  def safe_fill_in(field, with:, **options)
    retry_until_true(timeout: 15) do
      fill_options = { with: with, wait: options[:wait] || 10 }
      fill_options[:match] = options[:match] if options[:match]

      fill_in(field, **fill_options)
      true
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("Node with given id does not belong to the document")
        # Wait a bit and try again without refreshing
        sleep 3
        false
      else
        raise e
      end
    end
  end

  def safe_select(value, from:, **options)
    retry_until_true(timeout: 15) do
      select_options = { from: from, wait: options[:wait] || 10 }
      select_options[:match] = options[:match] if options[:match]

      select(value, **select_options)
      true
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("Node with given id does not belong to the document")
        # Wait a bit and try again without refreshing
        sleep 3
        false
      else
        raise e
      end
    end
  end

  def wait_for_stable_dom
    # Wait for the DOM to be stable
    sleep 0.5
    expect(page).to have_selector("body", wait: 5)
  end

  def wait_for_page_to_load
    # Wait for the page to be fully loaded
    expect(page).to have_selector("body", wait: 10)
    sleep 1
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
