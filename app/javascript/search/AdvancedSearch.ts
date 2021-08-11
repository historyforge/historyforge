import axios from 'axios'
import addAttributeFilter from "./addAttributeFilter";
import selectAttribute from "./selectAttribute";

// @ts-ignore
$.fn.advancedSearch = function(options: AdvancedSearchOptions): JQuery {
    return this.each(function() {
        $(this).data('search', new AdvancedSearch(this, options));
        return this;
    })
};

class AdvancedSearch implements IAdvancedSearch {
    currentFilters; attributeFilters; form

    constructor(form: JQuery, options: AdvancedSearchOptions) {
        this.currentFilters = options.filters;
        this.form = $(form);
        this.initFormEvents();
        axios.get(options.url).then((json) => {
            this.attributeFilters = json.data.filters;
            this.showCurrentFilters()
            this.showAddableFilters();
        })
    }

    initFormEvents(): void {
        // when you click toggle buttons like "unreviewed" and "unhoused" this submits the form
        $(document).on('click', '#new_s .btn-group-toggle label', () => {
            this.form.submit();
        });

        // on the fields dropdown there is a "check all" button
        this.form.find('.checkall').on('click', function(e) {
            e.stopPropagation();
            const $cont = $($(this).data('scope'));
            const $inputs = $cont.find('input[type=checkbox]');
            const checks = $inputs.filter(':checked').length;
            if (checks) {
                if (checks === $inputs.length) {
                    $inputs.removeAttr('checked');
                    $inputs.filter("[data-default=true]").trigger('click');
                } else {
                    $inputs.filter(':not(:checked)').trigger('click');
                }
            } else {
                $inputs.trigger('click');
            }
        });
    }

    // filters already applied are listed as buttons with an X that removes the filter
    showCurrentFilters(): void {
        if (Object.entries(this.currentFilters).length) {
            $('#attribute-filters').addClass('mb-3').empty();
            for (let scope in this.currentFilters) {
                const field_config = this.getFieldConfigFromScope(scope) ||
                    this.getFieldConfigFromScope(scope.replace(/_eq/, '_in'))
                if (field_config || field_config?.scopes) {
                    addAttributeFilter(field_config, scope, this.currentFilters[scope]);
                }
            }
        }
    }

    // underneath any quick filters is a dropdown that lets you select a field to filter on
    showAddableFilters(): void {
        $('select.scope').hide();
        $('.value-input-container').empty();
        const attrSelect = $('select.attribute');
        attrSelect.on('change', (event: JQuery.ChangeEvent) => {
            const attribute = $(event.target).val().toString();
            const config = this.attributeFilters[attribute]
            if (config) {
                selectAttribute(attribute, this.form, config)
            }
        });
        attrSelect.html("<option>Select field name</option>");
        Object.keys(this.attributeFilters).forEach((key) => {
            const config = this.attributeFilters[key];
            if (config.scopes) {
                attrSelect.append('<option value="' + key + '">' + config.label + '</option>');
            }
        });
    }

    // returns the field config from a scope name
    getFieldConfigFromScope(scope: string): AttributeFilterConfig {
        for (let attribute in this.attributeFilters) {
            const value = this.attributeFilters[attribute];
            if ((value.scopes != null ? value.scopes[scope] : void 0) != null) {
                return value;
            }
        }
    }
}
