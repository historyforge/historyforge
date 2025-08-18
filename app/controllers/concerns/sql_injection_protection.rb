# frozen_string_literal: true

module SqlInjectionProtection
  extend ActiveSupport::Concern

  included do
    before_action :detect_sql_injection_attempts, only: :index
  end

  private

  def detect_sql_injection_attempts
    return unless suspicious_sql_injection_detected?

    Rails.logger.warn "SQL injection attempt detected from #{request.remote_ip}: #{request.url}"

    # Return 404 to avoid revealing information about the application
    page_not_found
  end

  def suspicious_sql_injection_detected?
    # Check all parameters for SQL injection patterns
    all_params = params.to_unsafe_h

    all_params.any? do |_key, value|
      next false unless value.is_a?(String)

      sql_injection_patterns.any? { |pattern| value.match?(pattern) }
    end
  end

  def sql_injection_patterns
    [
      # Common SQL injection patterns
      /\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b/i,
      # Quote-based injection attempts
      /['"]\s*(or|and)\s*\d+\s*[=<>]\s*\d+/i,
      # Comment-based injection attempts
      /--\s*$/i,
      /\/\*.*\*\//i,
      # Boolean-based injection attempts
      /\b(or|and)\s+\d+\s*[+\-*\/]\s*\d+\s*[+\-*\/]\s*\d+\s*[+\-*\/]\s*\d+\s*=\s*\d+/i,
      # Simple boolean injection
      /\b(or|and)\s+\d+\s*=\s*\d+/i,
      # Stacked queries
      /;\s*(select|insert|update|delete|drop|create|alter|exec|execute)/i,
      # Time-based injection attempts
      /\b(sleep|benchmark|waitfor)\s*\(/i,
      # Error-based injection attempts
      /\b(extractvalue|updatexml|floor|rand)\s*\(/i,
    ]
  end
end
