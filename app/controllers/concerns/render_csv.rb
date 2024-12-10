# frozen_string_literal: true

# Provides the render_csv method which does what it suggests
module RenderCsv
  private

  def render_csv(filename, resource_class)
    # Loading the results first because Current.locality_id gets reset after headers are sent.
    # If the query hasn't run yet, then it never gets the locality scope.
    @search.results
    headers['X-Accel-Buffering'] = 'no'
    headers['Cache-Control'] = 'no-cache'
    headers['Content-Type'] = 'text/csv; charset=utf-8'
    headers['Content-Disposition'] = "attachment; filename=\"historyforge-#{filename}.csv\""
    headers['Last-Modified'] = Time.zone.now.ctime.to_s
    self.response_body = Enumerator.new do |csv|
      headers = @search.columns.map { |field| Translator.label(resource_class, field) }
      csv << CSV.generate_line(headers)
      @search.results.each do |row|
        row_results = @search.columns.map { |field| row.public_send(field) }
        csv << CSV.generate_line(row_results)
      end
    end
  end
end
