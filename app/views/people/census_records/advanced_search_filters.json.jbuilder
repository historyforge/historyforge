json.filters do
  census_form_renderer.new(json).render
  Census1940SupplementalFormFields.new(json).render if controller.year == 1940
end
