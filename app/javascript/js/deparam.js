// jQuery Deparam - v0.1.0 - 6/14/2011
// http://benalman.com/
// Copyright (c) 2011 Ben Alman; Licensed MIT, GPL

// Creating an internal undef value is safer than using undefined, in case it
// was ever overwritten.
let undef;

// A handy reference.
const decode = decodeURIComponent;

// Document $.deparam.
export default function(text) {
    // The object to be returned.
    const result = {};

    // Iterate over all key=value pairs.
    text.replace(/\+/g, ' ').split('&').forEach(function(pair) {
        // The key=value pair.
        var kv = pair.split('=');
        // The key, URI-decoded.
        var key = decode(kv[0]);
        // Abort if there's no key.
        if (!key) {
            return;
        }
        // The value, URI-decoded. If value is missing, use empty string.
        var value = decode(kv[1] || '');
        // If key is more complex than 'foo', like 'a[]' or 'a[b][c]', split it
        // into its component parts.
        var keys = key.split('][');
        var last = keys.length - 1;
        // Used when key is complex.
        var current = result;

        // If the first keys part contains [ and the last ends with ], then []
        // are correctly balanced.
        if (keys[0].indexOf('[') >= 0 && /\]$/.test(keys[last])) {
            // Remove the trailing ] from the last keys part.
            keys[last] = keys[last].replace(/\]$/, '');
            // Split first keys part into two parts on the [ and add them back onto
            // the beginning of the keys array.
            keys = keys.shift().split('[').concat(keys);
            // Since a key part was added, increment last.
            last++;
        } else {
            // Basic 'foo' style key.
            last = 0;
        }

        value = reviver(key, value);

        if (last) {
            // Complex key, like 'a[]' or 'a[b][c]'. At this point, the keys array
            // might look like ['a', ''] (array) or ['a', 'b', 'c'] (object).
            for (let i=0; i <= last; i++) {
                // If the current key part was specified, use that value as the array
                // index or object key. If omitted, assume an array and use the
                // array's length (effectively an array push).
                key = keys[i] !== '' ? keys[i] : current.length;
                if (i < last) {
                    // If not the last key part, update the reference to the current
                    // object/array, creating it if it doesn't already exist AND there's
                    // a next key. If the next key is non-numeric and not empty string,
                    // create an object, otherwise create an array.
                    current = current[key] = current[key] || (isNaN(keys[i + 1]) ? {} : []);
                } else {
                    // If the last key part, set the value.
                    current[key] = value;
                }
            }
        } else {
            // Simple key.
            if ($.isArray(result[key])) {
                // If the key already exists, and is an array, push the new value onto
                // the array.
                result[key].push(value);
            } else if (key in result) {
                // If the key already exists, and is NOT an array, turn it into an
                // array, pushing the new value onto it.
                result[key] = [result[key], value];
            } else {
                // Otherwise, just set the value.
                result[key] = value;
            }
        }
    });

    return result;
};

// Default reviver function, used when true is passed as the second argument
// to $.deparam. Don't like it? Pass your own!
function reviver(key, value) {
    var specials = {
        'true': true,
        'false': false,
        'null': null,
        'undefined': undef
    };

    return (+value + '') === value ? +value // Number
        : value in specials ? specials[value] // true, false, null, undefined
            : value; // String
}

