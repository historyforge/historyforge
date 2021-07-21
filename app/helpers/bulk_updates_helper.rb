module BulkUpdatesHelper
  # This exists so that bulk update can render the input of a census field outside of the context of its own form.
  # The bulk update form isn't a form_for a specific census record, but an operation that will change all matching
  # values to a new value.
  def bulk_update_field_for(field, form)
    "Census#{year}FormFields".safe_constantize.new(form).config_for(field.intern).dup
  end

  # Populates the dropdown of available fields for bulk update.
  def census_fields_select
    year = controller.year
    fields = "Census#{year}FormFields".safe_constantize.fields.dup
    inputs = "Census#{year}FormFields".safe_constantize.inputs.dup
    fields.reject { |field| inputs[field].kind_of?(Hash) && inputs[field][:as] == :divider }
          .map { |field| [translated_label(resource_class, field), field] }
  end
end
