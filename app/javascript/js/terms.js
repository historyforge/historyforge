$(document).ready(function() {
  $('.term-peeps').each(function() {
    const { year, baseUrl } = this.dataset
    const url = `${baseUrl}/peeps/${year}/1`
    $.getScript(url)
  })
})
