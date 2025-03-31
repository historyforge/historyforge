import { Application } from 'stimulus'

import AutoCompleteController from "./autocomplete_controller";
import BlowupController from "./blowup_controller";
import CensusAutoCompleteController from "./census_autocomplete_controller";
import LoadSavedSearchController from "./load_saved_search_controller";
import PhotoWizardController from "./photo_wizard_controller";
import DocumentController from "./document_controller.js";
import SaveSearchController from "./save_search_controller";
import SavedSearchesController from "./saved_searches_controller";

const definitions = [
    { identifier: 'auto-complete', controllerConstructor: AutoCompleteController },
    { identifier: 'blowup', controllerConstructor: BlowupController },
    { identifier: 'census-autocomplete', controllerConstructor: CensusAutoCompleteController },
    { identifier: 'load-saved-search', controllerConstructor: LoadSavedSearchController },
    { identifier: 'photo-wizard', controllerConstructor: PhotoWizardController },
    { identifier: 'document', controllerConstructor: DocumentController },
    { identifier: 'save-search', controllerConstructor: SaveSearchController },
    { identifier: 'saved-searches', controllerConstructor: SavedSearchesController },
]

const application = Application.start()
application.load(definitions)
