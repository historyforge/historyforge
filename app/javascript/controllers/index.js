import { Application } from 'stimulus'

import CensusBuildingPickerController from './census_building_picker_controller'
import CensusViewController from './census_view_controller'
import ChangeHistoryController from './change_history_controller'
import AutoCompleteController from "./autocomplete_controller";
import TermRecordsController from "./term_records_controller";
import CmsSliderController from "./cms_slider_controller";
import BlowupController from "./blowup_controller";
import RecordGridController from "./record_grid_controller";
import SearchScopeController from "./search_scope_controller";
import TooltipController from "./tooltip_controller";
import PasskeyPromptController from "./passkey_prompt_controller";
import HintPopoverController from "./hint_popover_controller";
import LoadSavedSearchController from "./load_saved_search_controller";
import CreatorPickerController from "./creator_picker_controller";
import CreationDateRangeController from "./creation_date_range_controller";
import PhotoWizardController from "./photo_wizard_controller";
import SaveSearchController from "./save_search_controller";
import SavedSearchesController from "./saved_searches_controller";

const definitions = [
    { identifier: 'census-building-picker', controllerConstructor: CensusBuildingPickerController },
    { identifier: 'census-view', controllerConstructor: CensusViewController },
    { identifier: 'change-history', controllerConstructor: ChangeHistoryController },
    { identifier: 'autocomplete', controllerConstructor: AutoCompleteController },
    { identifier: 'term-records', controllerConstructor: TermRecordsController },
    { identifier: 'cms-slider', controllerConstructor: CmsSliderController },
    { identifier: 'blowup', controllerConstructor: BlowupController },
    { identifier: 'record-grid', controllerConstructor: RecordGridController },
    { identifier: 'search-scope', controllerConstructor: SearchScopeController },
    { identifier: 'tooltip', controllerConstructor: TooltipController },
    { identifier: 'passkey-prompt', controllerConstructor: PasskeyPromptController },
    { identifier: 'hint-popover', controllerConstructor: HintPopoverController },
    { identifier: 'load-saved-search', controllerConstructor: LoadSavedSearchController },
    { identifier: 'creator-picker', controllerConstructor: CreatorPickerController },
    { identifier: 'creation-date-range', controllerConstructor: CreationDateRangeController },
    { identifier: 'photo-wizard', controllerConstructor: PhotoWizardController },
    { identifier: 'save-search', controllerConstructor: SaveSearchController },
    { identifier: 'saved-searches', controllerConstructor: SavedSearchesController },
]

const application = Application.start()
application.load(definitions)
