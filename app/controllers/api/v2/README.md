# API V2 Search Controller

A clean, idiomatic rewrite of the search functionality that generates GeoJSON from building search results.

## Usage

```
GET /api/v2/search?search=your_search_term
GET /api/v2/search?search=your_search_term&strict=true
GET /api/v2/search?search=your_search_term&strict=false
```

## Parameters

- **search** (required): The search term to look for
- **strict** (optional, default: true): Controls result filtering
  - `true` or omitted: Only return buildings with census records (original behavior)
  - `false`: Return buildings with census records OR other relevant content (narratives, media, etc.)

## Examples

```bash
# Strict mode (default) - only buildings with census data
curl "http://localhost:3000/api/v2/search?search=data-poi"

# Explicit strict mode
curl "http://localhost:3000/api/v2/search?search=data-poi&strict=true"

# Relaxed mode - includes buildings without census data but with other content
curl "http://localhost:3000/api/v2/search?search=data-poi&strict=false"
```

## Features

- **Clean Architecture**: Organized into focused, single-responsibility methods
- **Comprehensive Search**: Searches across buildings, people, census records, media, and rich text content
- **Multi-year Support**: Supports 1910 and 1920 census data
- **CORS Enabled**: Proper CORS handling for allowed origins
- **Efficient Queries**: Uses database-level searches where possible
- **Rich GeoJSON**: Returns detailed feature properties

## Search Scope

The controller searches across:

### Building Data
- Building name, notes, and descriptions
- Rich text descriptions
- Addresses

### Associated Media
- Photos (searchable text, descriptions, captions)
- Videos (searchable text, descriptions, captions) 
- Audios (searchable text, descriptions, captions)
- Documents (name, description)

### Narratives
- Source and notes text
- Rich text stories and sources

### Census & People Data
- Census records for 1910 and 1920
- People records (all searchable fields)
- People-associated media and narratives

## Response Format

Returns GeoJSON FeatureCollection with the following structure:

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [longitude, latitude]
      },
      "properties": {
        "location_id": "building_id",
        "title": "primary_address",
        "addresses": [...],
        "audios": [...],
        "videos": [...],
        "photos": [...],
        "documents": [...],
        "stories": [...],
        "description": "building_description"
      }
    }
  ]
}
```

## Key Improvements

1. **Separation of Concerns**: Each search type has its own method
2. **Database Efficiency**: Uses targeted joins instead of OR-heavy queries
3. **Error Handling**: Proper CORS validation and empty result handling
4. **Maintainability**: Clear method names and focused responsibilities
5. **Extensibility**: Easy to add new search types or modify existing ones

## Configuration

Update `ALLOWED_ORIGINS` constant to add new allowed origins:

```ruby
ALLOWED_ORIGINS = %w[
  http://localhost:5173 
  http://localhost:5174 
  https://greenwood.jacrys.com 
  https://jacrys.com
].freeze
```

Update `SEARCH_YEARS` to add support for additional census years:

```ruby
SEARCH_YEARS = %w[1910 1920 1930].freeze
```
