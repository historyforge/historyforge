module CensusRecordsHelper
  def census_form_renderer
    "Census#{controller.year}FormFields".constantize
  end

  def translated_label(klass, key)
    I18n.t("simple_form.labels.#{klass ? klass.name.underscore : nil}.#{key}", default:
      I18n.t("simple_form.labels.census_record.#{key}", default:
        I18n.t("simple_form.labels.defaults.#{key}", default: (klass ? klass : CensusRecord).human_attribute_name(key))))
  end

  def translated_option(attribute_name, item)
    I18n.t("#{attribute_name}.#{item.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: item).presence
  end

  def census_fields_select
    year = controller.year
    fields = if year == 1940
               "Census#{year}FormFields".constantize.fields.dup.concat("Census#{year}SupplementalFormFields".constantize.fields.dup)
             else
               "Census#{year}FormFields".constantize.fields.dup
             end
    fields.map { |name| [translated_label(resource_class, name), name] }
  end

  def bulk_update_field_for(field, form)
    "Census#{year}FormFields".safe_constantize.new(form).config_for(field.intern).dup
  rescue
    "Census#{year}SupplementalFormFields".safe_constantize.new(form).config_for(field.intern).dup
  end

  def select_options_for(collection)
    [["blank", 'nil']] + collection.zip(collection)
  end

  def yes_no_choices
    [["Left blank", nil], ["Yes", true], ["No", false]]
  end

  def prepare_blanks_for_1910_census(record)
    record.civil_war_vet     ||= 'nil' #if record.civil_war_vet.nil?
    # record.unemployed        = 'nil' if record.unemployed.nil?
    record.naturalized_alien ||= 'nil' #if record.naturalized_alien.nil?
    record.owned_or_rented   ||= 'nil' #if record.owned_or_rented.nil?
    record.mortgage          ||= 'nil' #if record.mortgage.nil?
    record.farm_or_house     ||= 'nil' #if record.farm_or_house.nil?
    record.civil_war_vet     ||= 'nil' #if record.civil_war_vet.nil?
    # record.can_read          = 'nil' if record.can_read.nil?
    # record.can_write         = 'nil' if record.can_write.nil?
    # record.attended_school   = 'nil' if record.attended_school.nil?
    # raise record.inspect
  end

  def yes_no_na(value)
    if value.nil?
      'blank'
    else
      value ? 'yes' : 'no'
    end
  end

  def is_1900?
    controller.year == 1900
  end

  def is_1910?
    controller.year == 1910
  end

  def is_1920?
    controller.year == 1920
  end

  def is_1930?
    controller.year == 1930
  end

  def is_1940?
    controller.year == 1940
  end

  def sheet_hint
    html = content_tag(:p, "The <u>Sheet</u> or page number is in the upper right corner in the header.".html_safe)
    html << image_pack_tag('media/images/1900/sheet-side.png') if is_1900?
    html << image_pack_tag('media/images/1910/sheet-side.png') if is_1910?
    html << image_pack_tag('media/images/1920/sheet-side.png') if is_1920?
    html << image_pack_tag('media/images/1940/sheet-side.png') if is_1940?
    raw html
  end

  def side_hint
    html = content_tag(:p, "Each census sheet has side <u>A</u> and <u>B</u>.".html_safe)
    html << image_pack_tag('media/images/1900/sheet-side.png') if is_1900?
    html << image_pack_tag('media/images/1910/sheet-side.png') if is_1910?
    html << image_pack_tag('media/images/1920/sheet-side.png') if is_1920?
    html << image_pack_tag('media/images/1940/sheet-side.png') if is_1940?
    raw html
  end

  def line_number_hint
    if is_1900?
      html = content_tag(:p, "The <u>Line</u> numbers are located in the margins on the left and right sides of the sheet.".html_safe)
    elsif is_1940?
      html = content_tag(:p, 'Each sheet has 40 lines. The line numbers are located on the left and right side of the sheet.'.html_safe)
      html << content_tag(:p, 'Side A usually contains lines 1-40 and Side B lines 41-80.'.html_safe)
    else
      html = content_tag(:p, "Each sheet has 50 lines. They are located in the margin on the left and right side of the sheet.".html_safe)
      html << content_tag(:p, "Side A usually contains lines 1-50 and Side B lines 51-100.".html_safe)
    end
    raw html
  end

  def ward_hint
    if is_1900?
      html = content_tag(:p, "The <u>Ward</u> is in the upper right corner of the sheet underneath the Sheet Number. Enter as a number (4).")
      html << image_pack_tag('media/images/1900/ward.png')
      raw html
    elsif is_1910?
      html = content_tag :p, "The ward is in the upper right corner in the header underneath the Enumeration District. Enter ward as a number (4).".html_safe
      html << image_pack_tag('media/images/1910/sheet-side.png')
      raw html
    elsif is_1920?
      html = content_tag :p, "The ward is in the upper right corner in the header underneath the Enumeration District. Enter ward as a number (2).".html_safe
      html << image_pack_tag('media/images/1920/sheet-side.png')
      raw html
    elsif is_1940?
      html = content_tag :p, "The ward is to the left of the center title \"Sixteenth Census of the United States: 1940\". Enter ward as a number (2).".html_safe
      html << image_pack_tag('media/images/1940/ward.png')
      raw html
    end
  end

  def enumeration_district_hint
    if is_1900?
      html = content_tag :p, "The <u>Enumeration District</u> is in the upper right corner in the header. Enter as a number (156).".html_safe
      html << image_pack_tag('media/images/1900/ed.png')
      raw html
    elsif is_1910?
      html = content_tag :p, "The Enumeration District is in the upper right corner in the header. Enter as a number (185).".html_safe
      html << image_pack_tag('media/images/1910/sheet-side.png')
      raw html
    elsif is_1920?
      html = content_tag :p, "The Enumeration District is in the upper right corner in the header underneath the Supervisor's District. Enter as a number (185).".html_safe
      html << image_pack_tag('media/images/1920/sheet-side.png')
      raw html
    elsif is_1940?
      html = content_tag :p, "The Enumeration District (ED) is in the upper right corner in the header next to the sheet number. Enter the last 2 digits only.".html_safe
      html << image_pack_tag('media/images/1940/sheet-side.png')
      raw html
    end
  end

  def house_number_hint
    html = ''
    html << content_tag(:p, "<u>Column 2.</u>".html_safe) if is_1920? || controller.year == 1940
    html << content_tag(:p, "If the number includes a fraction leave a space between the number and the fraction. i.e. 102 ½.".html_safe)
    html << content_tag(:p, "If the number indicates rear (as in rear apartment) enter the street number followed by a space and the word Rear, i.e. 313 Rear.".html_safe)
    html << content_tag(:p, "If the number includes a range enter as written, i.e. 102-104.".html_safe)
    raw html
  end

  def street_prefix_hint
    html = ''
    if is_1910?
      html << content_tag(:p, "The <u>Prefix</u> is located in the first column from the left.".html_safe)
      html << content_tag(:p, "It is the North, South, East, West preceding the street name.".html_safe)
      html << content_tag(:p, "<b>* Note:</b> On occasion, the street name will include North, South, East, or West, as in South Hill Terrace. In this case, you would include South in the street name, not the prefix.".html_safe)
    else
      html << content_tag(:p, "<u>Column 1.</u>".html_safe) if is_1920? || controller.year == 1940

      html << content_tag(:p, "North, South, East, West preceding the street name.".html_safe)
      html << content_tag(:p, "<b>Exception:</b> on occasion the street name will include North, South, East or West, as in South Hill Terrace.  In this case you would include South in the street address, not the prefix.".html_safe)
    end
    raw html
  end

  def street_name_hint
    html = ''
    if is_1910?
      html << content_tag(:p, "The <u>Street Name</u> is written horizontally in the first column from the left.".html_safe)
      html << content_tag(:p, "This refers to the name of the street itself (i.e. Tioga).".html_safe)
      html << content_tag(:p, "<b>* Note:</b> Street names can change at least once on the sheet. If there are multiple street names in column 1, look for a hand-drawn line separating the buildings on one street from the next.".html_safe)
    else
      html << content_tag(:p, "<u>Column 1.</u>".html_safe) if is_1920? || controller.year == 1940
      html << content_tag(:p, "The name of the street itself, i.e. Aurora. If you enter a space followed by the suffix into this column by mistake, make sure to delete both the suffix and the extra space.".html_safe)
      html << content_tag(:p, "<b>Note:</b> Street names can change at least once on the sheet.  These changes are often indicated by a hand-drawn line across the column separating the buildings on one street from the next.".html_safe)
    end
    raw html
  end

  def street_suffix_hint
    html = ''
    if is_1910?
      html << content_tag(:p, "The <u>Suffix</u> is located in the first column from the left.".html_safe)
      html << content_tag(:p, "It is the Ave, Rd, St, etc, following the street name.".html_safe)
      html << content_tag(:p, "<b>* Note:</b> If the enumerator omits the suffix, please check for the correct suffix and enter accordingly.".html_safe)
    else
      html << content_tag(:p, "Column 1.".html_safe) if is_1920? || controller.year == 1940
      html << content_tag(:p, "Avenue, Road, Street, etc. If you are unsure, check the city directory or search the HF building database for the street name to see how it has been entered before.".html_safe)
    end
    raw html
  end

  def apartment_number_hint
    content_tag(:p, 'Enter only when applicable. If no apartment number, leave blank.'.html_safe)
  end

  def building_hint
    html = content_tag :p, "There is no corresponding field on the census, however, this field allows us to link the people in the census to a mapped building. Once you have entered the address, select the building with the same address from the dropdown menu.".html_safe
    html << content_tag(:p, 'If the building does not appear in the menu:'.html_safe)
    html << content_tag(:p, '<u>First,</u> check to make sure that the street name is spelled correctly and does not have a space after it, and that the prefix and suffix are correct.'.html_safe)
    html << content_tag(:p, '<u>Second,</u> If the building still does not appear, check the box for <u>Add building with address</u>, if available. This will add the building for this and future records.'.html_safe)
    # html << content_tag(:p, "From the drop down menu select the building with the same address. If the building number is not listed, click Add building with address.")
    raw html
  end

  def locality_hint
    content_tag(:p, "This field is also not on the census but allows for the inclusion of multiple localities (cities, towns, villages, etc) in one database. If applicable, select the correct locality from the dropdown menu.".html_safe)
  end

  def dwelling_number_hint
    html = ''
    html << content_tag(:p, "<u>Column 1.</u>".html_safe) if is_1910?
    html << content_tag(:p, "<u>Column 3.</u>".html_safe) if is_1920?
    html << content_tag(:p, 'Enumerators were asked to number the dwellings in order of visitation. A building with multiple families but one entrance usually has a single dwelling number.'.html_safe)
    html << content_tag(:p, 'If the first person on the sheet is not the head of household, the dwelling and family numbers might be on the previous sheet.'.html_safe)
    html << content_tag(:p, '<b>* Note:</b> Dwelling and Family numbers are generally sequential.'.html_safe)
    # html << content_tag(:p, "A building with multiple families but one entrance usually has a single dwelling number. Enter as written.  *In some cases, if the first person on the sheet is not the head of household the dwelling and family numbers will not be listed but instead can be found on the previous census sheet.")
    # html << content_tag(:p, "<b>Note:</b> Dwelling and Family numbers are generally sequential.  If it is hard to read either number check the numbers above and below for a pattern.".html_safe)
    raw html
  end

  def family_id_hint
    html = ''
    html << content_tag(:p, "<u>Column 2.</u>".html_safe) if is_1910?
    html << content_tag(:p, "<u>Column 4.</u>".html_safe) if is_1920?
    html << content_tag(:p, "<u>Column 3.</u>".html_safe) if is_1940?
    if is_1910?
      html << content_tag(:p, 'Enumerators were asked to number the families in order of visitation.'.html_safe)
      html << content_tag(:p, "<b>Note:</b> Dwelling and Family numbers are generally sequential.".html_safe)
    else
      html << content_tag(:p, "Enter as written. In some cases, if the first person on the sheet is not the head of household the dwelling and family numbers will not be listed but instead can be found on the previous census sheet.".html_safe)
      html << content_tag(:p, "<b>Note:</b> Dwelling and Family numbers are generally sequential.  If it is hard to read either number check the numbers above and below for a pattern.".html_safe)
    end
    raw html
  end

  def name_hint
    if is_1910?
      html = content_tag(:p, '<u>Column 3.</u>'.html_safe)
      html << content_tag(:p, "Names are listed in the following order: Last, First, Middle.".html_safe)
      html << content_tag(:p, "The last name will be listed in the first record only, with a line or a blank space in the following records indicating it is to be repeated.".html_safe)
      html << image_pack_tag('media/images/1910/names.png')
      html << content_tag(:p, '<u>If the line is written over with a new last name, enter that as the last name.</u>'.html_safe)
      html << content_tag(:p, '<b>* Note:</b> If the record is in the same household as the previous record, the last name will be automatically populated after saving the previous record in this family. If the new record contains a different last name, highlight the last name and type in the correct one.'.html_safe)
    elsif is_1910?
      html = content_tag(:p, '<u>Column 3.</u>'.html_safe)
      html << content_tag(:p, "Names are listed in the following order: Last, First, Middle.".html_safe)
      html << content_tag(:p, "The last name will be listed in the first record only, with a line or a blank space in the following records indicating it is to be repeated.".html_safe)
      html << image_pack_tag('media/images/1910/names.png')
      html << content_tag(:p, 'Sometimes that line will be written over with a new last name, indicating that a member of the family/household had a different last name which should be entered.'.html_safe)
      html << content_tag(:p, '<b>* Note:</b> If the record is in the same household as the previous record, the last name will be automatically populated after saving the previous record in this family. If the new record contains a different last name, highlight the last name and type in the correct one.'.html_safe)
    else
      html = content_tag(:p, '<u>Column 7.</u>'.html_safe)
      html << content_tag(:p, "Names are listed Last, First, Middle. If several members of a family have the same last name, the last name will be listed in the first record and in following records it usually will be replaced by a line. Enter the last name for each individual. If there is no middle name or initial, leave the field blank.".html_safe)
      html << image_pack_tag('media/images/1940/names.png')
    end
    raw html
  end

  def last_name_hint
    html = ''
    html << content_tag(:p, '<u>Column 3.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 5.</u>'.html_safe) if is_1920?
    html << content_tag(:p, "Names are listed Last, First, Middle.".html_safe)
    html << content_tag(:p, "If several members of a family have the same last name, the last name will be listed in the first record and in following records it will be replaced by a line.".html_safe)
    html << content_tag(:p, "Enter the last name for each individual.".html_safe)
    if is_1920?
      html << image_pack_tag('media/images/1920/names.png')
    elsif is_1940?
      html << image_pack_tag('media/images/1940/names.png')
    else
      html << image_pack_tag('media/images/1910/names.png')
    end
    raw html
  end

  def middle_name_hint
    html = ''
    html << content_tag(:p, '<u>Column 3.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 5.</u>'.html_safe) if is_1920?
    html << content_tag(:p, "Names are listed Last, First, Middle.".html_safe)
    html << content_tag(:p, "If there is no middle name or initial leave the field blank.".html_safe)
    if is_1920?
      html << image_pack_tag('media/images/1920/names.png')
    elsif is_1940?
      html << image_pack_tag('media/images/1940/names.png')
    else
      html << image_pack_tag('media/images/1910/names.png')
    end
    raw html
  end

  def first_name_hint
    html = ''
    html << content_tag(:p, '<u>Column 3.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 5.</u>'.html_safe) if is_1920?
    html << content_tag(:p, "Names are listed Last, First, Middle.".html_safe)
    if is_1920?
      html << image_pack_tag('media/images/1920/names.png')
    elsif is_1940?
      html << image_pack_tag('media/images/1940/names.png')
    else
      html << image_pack_tag('media/images/1910/names.png')
    end
    raw html
  end

  def name_prefix_hint
    html = ''
    html << content_tag(:p, '<u>Column 3.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 5.</u>'.html_safe) if is_1920?
    html << content_tag(:p, 'Enter <u>only</u> if there is a Title (i.e. Dr., Mrs.) on the census sheet. If blank, leave blank. Omit periods.'.html_safe)
    raw html
  end

  def name_suffix_hint
    html = ''
    html << content_tag(:p, '<u>Column 3.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 5.</u>'.html_safe) if is_1920?
    html << content_tag(:p, 'Enter <u>only</u> if there is a Suffix (i.e. Jr., Sr.) on the census sheet. If blank, leave blank. Omit periods.'.html_safe)
    raw html
  end

  def title_hint
    html = ''
    html << content_tag(:p, '<u>Column 3.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 5.</u>'.html_safe) if is_1920?
    html << content_tag(:p, "Enter as written, if no title leave the field(s) blank.".html_safe)
    raw html
  end

  def suffix_hint
    html = ''
    html << content_tag(:p, '<u>Column 3.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 5.</u>'.html_safe) if is_1920?
    html << content_tag(:p, "Enter as written, if no suffix leave the field(s) blank.".html_safe)
    raw html
  end

  def relation_to_head_hint
    html = ''
    html << content_tag(:p, '<u>Column 4.</u>'.html_safe) if is_1900? || is_1910?
    html << content_tag(:p, '<u>Column 6.</u>'.html_safe) if is_1920?
    html << content_tag(:p, '<u>Column 7.</u>'.html_safe) if is_1940?
    if is_1900? || is_1910?
      html << content_tag(:p, "Enter as written. If this field is blank, enter the word <u>Blank</u> so you can save it.".html_safe)
    else
      html << content_tag(:p, "This field indicates the relationship of each person to the Head of the family (i.e. Head, Wife, Mother, Father, Son, Daughter, Grandson, Daughter-in-Law, Aunt, Uncle, Nephew, Niece, Boarder, Lodger, Servant, etc.). For the Head of household enter Head, do not the number to the right of Head.".html_safe)
      html << content_tag(:p, "For the census “family” is defined as “a group of persons living together in the same dwelling place.”".html_safe)
    end
    raw html
  end

  def owned_or_rented_hint(col=false)
    col = 26 if !col && controller.year == 1910
    col = 7 if !col && controller.year == 1920
    col = 4 if !col && controller.year == 1940
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    html << content_tag(:p, "Enter once for the family in the record in which it appears.".html_safe)
    html << content_tag(:p, "Select the option that corresponds to the answer indicated. If un (unknown), see image below, choose <u>Unknown</u>.".html_safe)
    html << image_pack_tag('media/images/1920/unknown-scribble.png')
    raw html
  end

  def home_value_hint
    html = content_tag(:p, '<u>Column 5.</u>'.html_safe)
    html << content_tag(:p, "For head of household only. Enter as written. If the response is Un (see image below), enter as 999.".html_safe)
    html << image_pack_tag('media/images/1920/unknown-scribble.png')
    raw html
  end

  def num_farm_sched_hint
    html = content_tag(:p, '<u>Column 29.</u>'.html_safe)
    html << content_tag(:p, "Enter once for the family in the record in which it appears.".html_safe)
    html << content_tag(:p, "Enter as written. If blank, leave blank.".html_safe)
    raw html
  end

  def lives_on_farm_hint
    html = content_tag(:p, '<u>Column 6.</u>'.html_safe)
    html << content_tag(:p, "Check the box if the response is yes.".html_safe)
    raw html
  end

  def mortgage_hint
    html = ''
    html << content_tag(:p, '<u>Column 8.</u>'.html_safe) if is_1920?
    html << content_tag(:p, "For head of household only.  Enter as written, generally M-Mortgage, F-Free of Mortgage.  If the response is Un (see image below), enter as Unknown.".html_safe)
    html << image_pack_tag('media/images/1920/unknown-scribble.png')
    raw html
  end

  def sex_hint
    if is_1910?
      html = ''
      html << content_tag(:p, '<u>Column 5.</u>'.html_safe)
      html << content_tag(:p, 'Select the option that corresponds to the answer indicated.'.html_safe)
      return raw html
    end

    return unless controller.year == 1920 || controller.year == 1940
    html = ''
    html << content_tag(:p, '<u>Column 9.</u>'.html_safe)
    html << content_tag(:p, 'Check the box that corresponds to the answer indicated.'.html_safe)
    raw html
  end

  def race_hint
    if is_1910?
      html = ''
      html << content_tag(:p, '<u>Column 6.</u>'.html_safe)
      html << content_tag(:p, 'Select the option that corresponds to the answer indicated.'.html_safe)
      return raw html
    end

    return unless controller.year == 1920 || controller.year == 1940
    html = ''
    html << content_tag(:p, '<u>Column 10.</u>'.html_safe)
    html << content_tag(:p, 'Check the box that corresponds to the answer indicated.'.html_safe)
    raw html
  end

  def age_hint
    html = ''
    html << content_tag(:p, '<u>Column 7.</u>'.html_safe) if is_1910?
    html << content_tag(:p, '<u>Column 11.</u>'.html_safe) if is_1920? || controller.year == 1940

    if is_1910?
      html << content_tag(:p, "Enter as written. If the response is un (unknown), see image below, enter <u>999</u> in the <u>Age</u> field.".html_safe)
      html << image_pack_tag('media/images/1910/unknown-scribble.png')
    else
      html << content_tag(:p, "Enter 999 for unknown or leave blank if taker left empty".html_safe)
      if is_1940?
        html << content_tag(:p, "A child that is <b>less than one year of age</b> will be listed by their age in months i.e. 3/12 or 11/12.".html_safe)
      else
        html << content_tag(:p, "A child 5 years of age or under will likely be listed by their age in years and months i.e. 4 and 3/12 or 11/12. If the child is 5 or under enter the age in years in the Age field and the age in months in Age (months).".html_safe)
      end
      html << content_tag(:p, "If they are less than 1 enter O in the Age field, then enter the months in Age (months)".html_safe)
    end
    raw html
  end

  def age_months_hint
    html = ''
    html << content_tag(:p, '<u>Column 7.</u>'.html_safe)
    html << content_tag(:p, 'For children whose age is listed in months, i.e. 3/12 or 1 7/12, enter the <u>age in years</u> in the <u>Age</u> field if there is one, and the <u>age in months</u> in the <u>Age (months)</u> field.'.html_safe)
    raw html
  end

  def marital_status_hint
    if is_1910?
      html = content_tag(:p, '<u>Column 8.</u>'.html_safe)
      html << content_tag(:p, 'M or M1: first marriage<br />M2 or M3: subsequent marriages'.html_safe)
    else
      html = content_tag(:p, '<u>Column 12.</u>'.html_safe)
    end
    html << content_tag(:p, 'Select the option that corresponds to the answer indicated.'.html_safe)
    raw html
  end

  def column_hint(col=false)
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    raw html
  end

  def years_married_hint
    html = ''
    html << content_tag(:p, "<u>Column 9.</u>".html_safe) if is_1910?
    html << content_tag(:p, "Enter as written. If the answer is un (unknown), see image below, enter <u>999</u>. If blank, leave blank.".html_safe)
    html << image_pack_tag('media/images/1910/unknown-scribble.png')
    raw html
  end

  def num_children_born_hint
    html = ''
    html << content_tag(:p, "<u>Column 10.</u>".html_safe) if is_1910?
    html << content_tag(:p, "Enter as written.".html_safe)
    raw html
  end

  def num_children_alive_hint
    html = ''
    html << content_tag(:p, "<u>Column 11.</u>".html_safe) if is_1910?
    html << content_tag(:p, "Enter as written.".html_safe)
    raw html
  end

  def foreign_born_hint
    return unless controller.year == 1920

    html = content_tag :p, 'There is no corresponding field on the census.  Check this box if the individual is not born in the United States (see column 19).'.html_safe
    raw html
  end

  def foreign_born_1910_hint
    html = content_tag :p, 'There is no corresponding field on the census.  Check this box if the individual was not born in the United States <b>EXCEPT</b> if the person has the designation <u>Am Cit</u> after their place of birth.'.html_safe
    raw html
  end

  def year_immigrated_hint
    html = ''
    html << content_tag(:p, "<u>Column 15.</u>".html_safe) if is_1910?
    html << content_tag(:p, "Enter as written. If blank, leave blank. If the response is un (unknown), see image below, choose <u>Unknown</u>.".html_safe)
    html << image_pack_tag('media/images/1910/unknown-scribble.png')
    raw html
  end

  def naturalization_hint
    html = ''
    html << content_tag(:p, "<u>Column 16.</u>".html_safe) if is_1910?
    html << content_tag(:p, "Select the option that corresponds to the answer indicated. If the response is un (unknown), see image below, choose <u>Unknown</u>.".html_safe)
    html << image_pack_tag('media/images/1910/unknown-scribble.png')
    html << content_tag(:p, "<u>* Enter naturalization status if it was recorded for a native-born woman.</u> From 1907 to 1922, native-born women who married foreign-born men acquired the citizenship status of their husband.".html_safe)
    raw html
  end

  def boolean_hint(col=false)
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    html << content_tag(:p, "Check the box if the response is yes. Leave blank in all other cases.".html_safe)
    raw html
  end

  def unknown_year_hint(col=false)
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    html << content_tag(:p, "Enter as written, leave blank if blank.  If the response is Un (see image below), enter as 999.".html_safe)
    raw html
  end

  def unknown_hint(col=false)
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    html << content_tag(:p, "Enter as written, leave blank if blank.  If the response is Un (see image below), enter as Unknown.".html_safe)
    html << image_pack_tag('media/images/1920/unknown-scribble.png')
    raw html
  end

  def farm_schedule_hint(col=false)
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    html << content_tag(:p, " If a 1- or 2-digit number, enter here.  If a 3-digit number, enter under Employment code.".html_safe)
    raw html
  end

  def mother_tongue_hint(col=false)
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    html << content_tag(:p, "Generally, for foreign born only.  Enter as written, leave blank if blank.  If the enumerator wrote un (see below) or don’t know enter Unknown.".html_safe)
    html << image_pack_tag('media/images/1920/unknown-scribble.png')
    raw html
  end

  def language_spoken_hint
    html = content_tag(:p, "<u>Column 17.</u>".html_safe)
    html << content_tag(:p, "Enter as written. If blank, leave blank.".html_safe)
    raw html
  end

  def profession_hint
    html = content_tag(:p, "<u>Column 18.</u>".html_safe)
    html << content_tag(:p, "\"None\" is the default which can be overwritten by highlighting the field and typing the correct response. Enter as written. Do not spell out abbreviations.".html_safe)
    raw html
  end

  def industry_hint
    html = content_tag(:p, "<u>Column 19.</u>".html_safe)
    html << content_tag(:p, "Enter as written. Do not spell out abbreviations. If blank, leave blank.".html_safe)
    raw html
  end

  def employment_hint
    html = content_tag(:p, "<u>Column 20.</u>".html_safe)
    html << content_tag(:p, "Select the option that corresponds to the answer indicated.".html_safe)
    raw html
  end

  def unemployed_weeks_hint
    html = content_tag(:p, "<u>Column 22.</u>".html_safe)
    html << content_tag(:p, "Enter as written. If blank, leave blank.".html_safe)
    raw html
  end

  def pob_hint(col=false)
    html = ''
    html << content_tag(:p, "<u>Column #{col}.</u>".html_safe) if col
    html << content_tag(:p, "New York is the default which can be overwritten. Enter the State/Territory/Country name as written by the enumerator, if the enumerator abbreviated, spell out the place of birth.".html_safe)
    html << content_tag(:p, "Enter US or variants as <u>United States</u>".html_safe)
    html << content_tag(:p, "Enter Washington D.C. as <u>District of Columbia</u>.".html_safe)
    html << content_tag(:p, "Those born abroad of American parents will have the designation <u>Am Cit</u> after their place of birth. Include that in the place of birth field.".html_safe)
    raw html
  end

  def pob_1910_hint(column)
    html = ''
    html << content_tag(:p, "<u>Column #{column}.</u>".html_safe)
    html << content_tag(:p, "Enter as written except:".html_safe)
    html << content_tag(:p, "If abbreviated write the full name of the State or Territory.".html_safe)
    html << content_tag(:p, "Enter <u>US</u> or variants as <u>United States</u>.".html_safe)
    html << content_tag(:p, "Enter <u>Washington D.C.</u> as <u>District of Columbia</u>.".html_safe)
    html << content_tag(:p, "A person born abroad of American parents should have the designation <u>Am Cit</u> after their place of birth. Enter the place of birth followed by (Am Cit).".html_safe)
    html << content_tag(:p, "For example, if the place of birth is <u>Japan-Am Cit</u>, select <u>Japan (Am Cit)</u> from the dropdown menu.".html_safe)
    html << content_tag(:p, "* For foreign born individuals: The place of birth column on the census sheet includes their <u>place of birth</u> and <u>mother tongue</u> (usually written out in full). Enter the full name of the mother tongue in its own field.".html_safe)
    raw html
  end

  def mother_tongue_1910_hint(column)
    html = ''
    html << content_tag(:p, "<u>Column #{column}.</u>".html_safe)
    html << content_tag(:p, "Generally for foreign born only. Spell out in full if abbreviated. If blank, leave blank. If the enumerator wrote un (unknown) or <u>Don't Know</u>, enter <u>Unknown</u>.".html_safe)
    html << image_pack_tag('media/images/1910/unknown-scribble.png')
    raw html
  end

  def pob_1940_hint(column)
    html = ''
    html << content_tag(:p, "<u>Column #{column}.</u>".html_safe)
    html << content_tag(:p, "New York is the default which can be overwritten. Enter the State/Territory/Country name as written by the enumerator, if the enumerator abbreviated, spell out the place of birth.".html_safe)
    html << content_tag(:p, "Enter US or variants as <u>United States</u>".html_safe)
    html << content_tag(:p, "Enter Washington D.C. as <u>District of Columbia</u>.".html_safe)
    html << content_tag(:p, "Make sure to capture whether <u>Canada French</u> or <u>Canada English</u>, <u>Irish Free State</u> or <u>Northern Ireland</u>.".html_safe)
    raw html
  end

  def attended_school_hint
    html = ''
    html << content_tag(:p, '<u>Column 16.</u>'.html_safe) if is_1920?
    html << content_tag(:p, '<u>Column 13.</u>'.html_safe) if is_1940?
    html << content_tag(:p, "Only check if the response is yes.".html_safe)
    raw html
  end

  def grade_completed_hint
    html = content_tag(:p, '<u>Column 14.</u>'.html_safe)
    html << image_pack_tag('media/images/1940/grade-completed.png')
    raw html
  end

  def employment_code_hint
    html = content_tag :p, "There is no official column for this on the census, these 3-digit numbers which range from 000-999 were added in the right margin or sometimes under farm number. Please enter the numbers here.".html_safe
    raw html
  end

  def citizenship_hint
    html = content_tag(:p, '<u>Column 16.</u>'.html_safe)
    html << content_tag(:p, 'The number 4 is a code for "Unknown".')
    html << image_pack_tag('media/images/1940/citizenship.png')
    raw html
  end

  def residence_1935_town_hint
    html = content_tag(:p, '<u>Column 17.</u> Enter as written.'.html_safe)
    html << content_tag(:p, "Those who lived in the same house in 1935 will be listed as <u>Same House</u>.".html_safe)
    html << content_tag(:p, "Those who lived in a different house in the same city, town, or village will be listed as <u>Same Place</u>.".html_safe)
    html << content_tag(:p, "Those who lived in a rural area will be listed as <u>R</u>.".html_safe)
    raw html
  end

  def occupation_code_hint(column)
    html = content_tag(:p, "<u>Column #{column}.</u>".html_safe)
    html << content_tag(:p, 'This is a three-figure code followed by a two-figure industry code and a 1-figure worker class code.'.html_safe)
    html << content_tag(:p, 'The <b>occupation</b> code can contain a <b>"V"</b> or an <b>"X"</b> as well as numbers.'.html_safe)
    html << content_tag(:p, 'The <b>industry</b> code can contain a <b>"V"</b> or an <b>"X"</b> as well as numbers.'.html_safe)
    html << content_tag(:p, 'The <b>worker class</b> code is a number from 1 to 6.'.html_safe)
    html << image_pack_tag('media/images/1940/occupation-codes.png')
    raw html
  end

  def civil_war_hint
    html = content_tag(:p, "<u>Column 30.</u>".html_safe)
    html << content_tag(:p, "Select the option that corresponds to the answer indicated. If un (unknown) choose <u>Unknown</u>.".html_safe)
    html << image_pack_tag('media/images/1910/unknown-scribble.png')
    html << content_tag(:p, "* If columns 30-32 contain a code (see image below) rather than answers to the questions, <u>leave the corresponding fields blank.</u>".html_safe)
    html << image_pack_tag('media/images/1910/punch-card-symbols.png')
    html << content_tag(:p, "These annotations were key-punch symbols used for post-enumeration processing of the census.".html_safe)
    raw html
  end

  def notes_hint
    html = content_tag :p, "If you find additional or conflicting information about the person from a different source such as a different name spelling or address, include the information as written by the enumerator in the relevant field and enter the alternative information here and its source. If you checked the city directory, include the year. i.e. The address in the 1919 City Directory is _________________. ".html_safe
    html << content_tag(:p, "<b>* Important</b> - the information in the notes field will become public.".html_safe)
    raw html
  end
end
