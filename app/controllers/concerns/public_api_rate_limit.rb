# frozen_string_literal: true

module PublicApiRateLimit
  extend ActiveSupport::Concern

  WINDOW = 1.minute
  STORE = ActiveSupport::Cache::MemoryStore.new
  REQUESTS_PER_MINUTE = Integer(ENV.fetch('API_REQUESTS_PER_MINUTE', '120'), 10)

  included do
    if REQUESTS_PER_MINUTE.positive?
      rate_limit to: REQUESTS_PER_MINUTE, within: WINDOW, store: STORE,
                 scope: 'public-api', with: :rate_limit_exceeded,
                 if: -> { request.get? || request.head? }
    end
  end

  private

  def rate_limit_exceeded
    no_store
    response.set_header('Retry-After', WINDOW.to_i.to_s)
    render json: { error: 'rate_limit_exceeded' }, status: :too_many_requests
  end
end
