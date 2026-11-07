# Public Person API v1

`GET /api/v1/people/:id` returns one Person as `application/json`. The `.json`
suffix is optional. The endpoint requires the installation's **Enabled Public**
People setting. It requires no login and uses the same census permissions as
the HTML Person page. Anonymous callers receive reviewed records from public
census years. Signed-in callers may receive additional records their permissions
allow. Signed-in responses are marked `Cache-Control: no-store`. The endpoint
has no write operations.

| Field | Meaning |
| --- | --- |
| `id`, `name`, `canonical_url` | The installation's numeric Person ID, display name, and absolute URL of the HTML Person page. Use the canonical URL to identify the Person across installations. |
| `alternate_names` | The alternate names shown on the Person page. |
| `summary`, `description` | The census narrative and a plain-text description. The narrative can be `null` when the readable rows do not support an account of residence, household, school, or work. The description uses the narrative when available and otherwise uses the Person's public description as plain text. |
| `summary_source_links` | The census records cited in the narrative, each with `year`, `record_id`, `url`, and a display `label`. This can include a readable household head's row in addition to the Person's own observations. |
| `birth_year`, `death_year` | Integer years explicitly marked as non-estimated on the Person, or `null`. |
| `census_observations` | Records the caller can read, ordered by year then record ID. Each has `id`, `year`, `name`, `occupation`, `race`, `sex`, `age`, and `pob`. `relation_to_head` is present where the census supports it. Values are as stored and can include nulls, codes, or transcription markers. |
| `source_links` | One link per observation, with `year`, `record_id`, and the absolute census record `url`. Join using the observation's `year` and `id` together. Record IDs can repeat across census years. |
| `relationships` | Evidence of a shared census household. Each item has `type` (`census_household_member`), the related `person_id` and `person_url`, and `source_links` for the two supporting records. A Person can appear more than once when multiple records support the relationship. The related Person is linked by URL, and the household link does not establish kinship. |

Collections are empty arrays when there is no readable evidence. A disabled public
endpoint or a denied read returns HTTP 403 with `{"error":"forbidden"}`. An
unknown numeric Person ID returns HTTP 404 with `{"error":"not_found"}` when
public access is enabled.
