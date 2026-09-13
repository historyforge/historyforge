# frozen_string_literal: true

# Wrap the whole Rails stack, including static files and redirects.
class IndexingPolicy
  def initialize(app, disallow_indexing: ENV['DISALLOW_INDEXING'] == 'true')
    @app = app
    @disallow_indexing = disallow_indexing
  end

  def call(env)
    return @app.call(env) unless @disallow_indexing

    status, headers, body = @app.call(env)
    [status, headers.merge('x-robots-tag' => 'noindex, nofollow'), body]
  end
end
