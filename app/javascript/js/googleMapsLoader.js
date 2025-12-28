/**
 * Shared Google Maps API Loader Utility
 * 
 * Provides a consistent way to use the Google Maps API using the importLibrary pattern.
 * Works with the loader script that should be included in the page HTML.
 */

/**
 * Loads the Google Maps API library using importLibrary
 * Assumes the loader script has been included in the page (via HTML)
 * @param {string} library - The library to load (e.g., 'maps', 'places')
 * @returns {Promise} - Promise that resolves when the library is ready
 */
export function loadGoogleMapsLibrary(library = 'maps') {
  // Check if API is available
  if (!isGoogleMapsAvailable()) {
    return Promise.reject(new Error('Google Maps API loader script not found. Ensure the loader script is included in the page HTML.'));
  }

  return google.maps.importLibrary(library);
}

/**
 * Checks if Google Maps API is available
 * @returns {boolean} - True if API is loaded and available
 */
export function isGoogleMapsAvailable() {
  return typeof google !== 'undefined' &&
    google.maps &&
    google.maps.importLibrary;
}

/**
 * Waits for Google Maps API to become available (useful when loader script loads asynchronously)
 * @param {number} timeout - Maximum time to wait in milliseconds (default: 10000)
 * @returns {Promise} - Promise that resolves when API is available or rejects on timeout
 */
export function waitForGoogleMaps(timeout = 10000) {
  if (isGoogleMapsAvailable()) {
    return Promise.resolve();
  }

  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    const checkInterval = setInterval(() => {
      if (isGoogleMapsAvailable()) {
        clearInterval(checkInterval);
        resolve();
      } else if (Date.now() - startTime > timeout) {
        clearInterval(checkInterval);
        reject(new Error('Google Maps API did not load within timeout period'));
      }
    }, 100);
  });
}

