module RenderCsv
  private

  def render_csv
    filename = 'historyforge-buildings.csv'
    headers['X-Accel-Buffering'] = 'no'
    headers['Cache-Control'] = 'no-cache'
    headers['Content-Type'] = 'text/csv; charset=utf-8'
    headers['Content-Disposition'] =
      %(attachment; filename="#{filename}")
    headers['Last-Modified'] = Time.zone.now.ctime.to_s
    self.response_body = Enumerator.new do |output|
      @search.to_csv(output)
    end
  end
end
