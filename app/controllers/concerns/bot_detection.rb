# frozen_string_literal: true

module BotDetection
  extend ActiveSupport::Concern

  BOT_PATTERNS = [
    # Search engine crawlers
    /googlebot/i,
    /bingbot/i,
    /slurp/i, # Yahoo
    /duckduckbot/i,
    /baiduspider/i,
    /yandexbot/i,
    /sogou/i,
    /exabot/i,
    /facebot/i,
    /ia_archiver/i,
    # AI agents and LLM crawlers
    /gptbot/i, # OpenAI GPTBot
    /chatgpt/i, # ChatGPT
    /anthropic/i, # Anthropic (Claude)
    /claude/i, # Claude
    /perplexity/i, # Perplexity AI
    /bingpreview/i, # Bing Chat/Preview
    /ccbot/i, # Common Crawl (used by AI training)
    /applebot/i, # Apple (may include AI features)
    /omniabot/i, # Various AI services
    # General bot patterns (keep these last as they're broader)
    /crawler/i,
    /spider/i,
    /bot/i
  ].freeze

  included do
    helper_method :bot?
  end

  def bot?
    return false unless request.user_agent.present?

    user_agent = request.user_agent.downcase
    BOT_PATTERNS.any? { |pattern| user_agent.match?(pattern) }
  end
end

