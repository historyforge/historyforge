// Utility function to convert ArrayBuffer to Base64URL (WebAuthn format)
// Base64URL uses - and _ instead of + and /, and has no padding
function arrayBufferToBase64URL(buffer) {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  const base64 = btoa(binary);
  return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

// Utility function to convert Base64 string to ArrayBuffer
// Handles both standard and URL-safe base64
function base64ToArrayBuffer(base64) {
  let base64String = base64.replace(/-/g, '+').replace(/_/g, '/');

  while (base64String.length % 4) {
    base64String += '=';
  }

  const binaryString = atob(base64String);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

// Auto-generate device label from user agent
function generateDeviceLabel() {
  const ua = navigator.userAgent;
  const platform = navigator.platform;

  if (/iPhone|iPad|iPod/.test(ua)) {
    return /iPhone/.test(ua) ? 'iPhone' : 'iPad';
  } else if (/Mac/.test(platform)) {
    if (/MacBook Air/.test(ua)) return 'MacBook Air';
    if (/MacBook Pro/.test(ua)) return 'MacBook Pro';
    return 'Mac';
  } else if (/Win/.test(platform)) {
    return 'Windows PC';
  } else if (/Linux/.test(platform)) {
    return 'Linux Device';
  } else if (/Android/.test(ua)) {
    return 'Android Device';
  }

  if (/Chrome/.test(ua)) return 'Chrome Browser';
  if (/Firefox/.test(ua)) return 'Firefox Browser';
  if (/Safari/.test(ua)) return 'Safari Browser';
  if (/Edge/.test(ua)) return 'Edge Browser';

  return 'Device';
}

// Build publicKey options for navigator.credentials.get (authentication)
// Uses native JSON helpers when available, falls back to manual conversion
function buildGetOptions(options) {
  if (window.PublicKeyCredential?.parseRequestOptionsFromJSON) {
    return PublicKeyCredential.parseRequestOptionsFromJSON(options);
  }

  const challengeBuffer = typeof options.challenge === 'string'
    ? base64ToArrayBuffer(options.challenge)
    : options.challenge;

  let allowCredentials;
  if (options.allowCredentials && Array.isArray(options.allowCredentials) && options.allowCredentials.length > 0) {
    allowCredentials = options.allowCredentials.map(cred => ({
      ...cred,
      id: typeof cred.id === 'string' ? base64ToArrayBuffer(cred.id) : cred.id
    }));
  }

  return {
    challenge: challengeBuffer,
    timeout: options.timeout || 120000,
    rpId: options.rpId,
    allowCredentials: allowCredentials,
    userVerification: options.userVerification || 'preferred'
  };
}

// Build publicKey options for navigator.credentials.create (registration)
// Uses native JSON helpers when available, falls back to manual conversion
function buildCreateOptions(options) {
  if (window.PublicKeyCredential?.parseCreationOptionsFromJSON) {
    return PublicKeyCredential.parseCreationOptionsFromJSON(options);
  }

  if (!options.challenge) {
    throw new Error('Server did not provide a challenge.');
  }
  if (!options.user?.id) {
    throw new Error('Server challenge response is missing required user.id');
  }
  if (!options.rp?.name) {
    throw new Error('Server challenge response is missing required rp.name');
  }

  return {
    ...options,
    challenge: base64ToArrayBuffer(options.challenge),
    user: {
      ...options.user,
      id: base64ToArrayBuffer(options.user.id)
    },
    excludeCredentials: (options.excludeCredentials || []).map(cred => ({
      ...cred,
      id: typeof cred.id === 'string' ? base64ToArrayBuffer(cred.id) : cred.id
    }))
  };
}

// Serialize a credential response to a plain JSON-safe object
// Uses native toJSON() when available, falls back to manual conversion
function credentialGetToJSON(credential) {
  if (credential.toJSON) return credential.toJSON();

  return {
    id: credential.id,
    rawId: arrayBufferToBase64URL(credential.rawId),
    type: 'public-key',
    response: {
      authenticatorData: arrayBufferToBase64URL(credential.response.authenticatorData),
      clientDataJSON: arrayBufferToBase64URL(credential.response.clientDataJSON),
      signature: arrayBufferToBase64URL(credential.response.signature),
      userHandle: credential.response.userHandle ? arrayBufferToBase64URL(credential.response.userHandle) : null
    }
  };
}

function credentialCreateToJSON(credential) {
  if (credential.toJSON) return credential.toJSON();

  return {
    id: credential.id,
    rawId: arrayBufferToBase64URL(credential.rawId),
    type: 'public-key',
    response: {
      attestationObject: arrayBufferToBase64URL(credential.response.attestationObject),
      clientDataJSON: arrayBufferToBase64URL(credential.response.clientDataJSON)
    }
  };
}

// Authenticate with passkey
export async function authenticateWithPasskey(challengeUrl, sessionUrl, afterSignInUrl) {
  // Get challenge from server
  const response = await fetch(challengeUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
    },
    credentials: 'same-origin'
  });

  if (!response.ok) {
    throw new Error('Failed to get challenge: ' + response.statusText);
  }

  const options = await response.json();
  const publicKeyOptions = buildGetOptions(options);

  const credential = await navigator.credentials.get({
    publicKey: publicKeyOptions,
    mediation: 'optional'
  });

  if (!credential) {
    throw new Error('No credential returned - user may have cancelled');
  }

  const credentialData = credentialGetToJSON(credential);

  // The devise-passkeys strategy reads params[:user][:passkey_credential]
  const authResponse = await fetch(sessionUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Accept': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
    },
    credentials: 'same-origin',
    body: new URLSearchParams({
      'user[passkey_credential]': JSON.stringify(credentialData)
    }).toString()
  });

  if (authResponse.ok) {
    let redirectUrl = afterSignInUrl;
    try {
      const json = await authResponse.json();
      if (json.redirect_url) redirectUrl = json.redirect_url;
    } catch (_) { /* use default */ }
    window.location.href = redirectUrl;
  } else {
    const errorText = await authResponse.text();
    throw new Error('Authentication failed: ' + (errorText || authResponse.statusText));
  }
}

// Register a new passkey
export async function registerPasskey(challengeUrl, createUrl, label) {
  const challengeResponse = await fetch(challengeUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
    },
    credentials: 'same-origin'
  });

  if (!challengeResponse.ok) {
    const errorText = await challengeResponse.text();
    throw new Error(`Failed to get challenge: ${errorText}`);
  }

  const options = await challengeResponse.json();
  const publicKeyOptions = buildCreateOptions(options);

  const credential = await navigator.credentials.create({ publicKey: publicKeyOptions });

  if (!credential) {
    throw new Error('Failed to create passkey');
  }

  const credentialData = credentialCreateToJSON(credential);

  const createResponse = await fetch(createUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
      'Accept': 'application/json'
    },
    credentials: 'same-origin',
    body: JSON.stringify({
      passkey: {
        label: label || generateDeviceLabel(),
        credential: JSON.stringify(credentialData)
      }
    })
  });

  if (createResponse.ok) {
    window.location.reload();
  } else {
    const errorText = await createResponse.text();
    let errorMessage = 'Unknown error';
    try {
      const errorJson = JSON.parse(errorText);
      errorMessage = errorJson.message || errorJson.error || errorMessage;
    } catch (_) {
      errorMessage = errorText || errorMessage;
    }
    throw new Error(errorMessage);
  }
}

// Track if handler is already attached to prevent duplicates
const registeredHandlers = new WeakSet();

// Initialize passkey registration form
export function initializePasskeyRegistration(formId, challengeUrl, createUrl) {
  const registerBtn = document.getElementById('register-passkey-btn');

  if (!registerBtn) return;
  if (registeredHandlers.has(registerBtn)) return;

  if (window.PublicKeyCredential) {
    const btnChallengeUrl = registerBtn.dataset.challengeUrl || challengeUrl;
    const btnCreateUrl = registerBtn.dataset.createUrl || createUrl;

    const clickHandler = async function (e) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();

      const labelInput = document.getElementById('passkey-label-input');
      const label = labelInput && labelInput.value.trim() ? labelInput.value.trim() : generateDeviceLabel();

      try {
        registerBtn.disabled = true;
        registerBtn.textContent = 'Registering...';
        await registerPasskey(btnChallengeUrl, btnCreateUrl, label);
      } catch (error) {
        alert('Failed to register passkey: ' + error.message);
        registerBtn.disabled = false;
        registerBtn.textContent = 'Register Passkey';
      }
    };

    registerBtn.addEventListener('click', clickHandler);
    registeredHandlers.add(registerBtn);
  } else {
    registerBtn.disabled = true;
    registerBtn.title = 'Passkeys are not supported in this browser';
  }
}

// Cookie helpers
function getCookie(name) {
  const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
  return match ? match[2] : null;
}

function setCookie(name, value, days) {
  const expires = new Date(Date.now() + days * 864e5).toUTCString();
  document.cookie = name + '=' + value + '; expires=' + expires + '; path=/; SameSite=Lax';
}

// Show a modal prompting the user to register a passkey after password login
function initializePasskeyPrompt() {
  if (!window.PublicKeyCredential) return;
  if (getCookie('passkey_prompt_dismissed')) return;

  const modal = document.getElementById('passkeyPromptModal');
  if (!modal) return;

  const setupBtn = document.getElementById('passkey-prompt-setup');
  const dismissBtn = document.getElementById('passkey-prompt-dismiss');

  if (!setupBtn) return;

  const challengeUrl = setupBtn.dataset.challengeUrl;
  const createUrl = setupBtn.dataset.createUrl;

  if (!challengeUrl || !createUrl) return;

  // Show the modal
  jQuery('#passkeyPromptModal').modal('show');

  // "Set up" button: register passkey with auto-generated label
  setupBtn.addEventListener('click', async function () {
    setupBtn.disabled = true;
    setupBtn.textContent = 'Setting up...';

    try {
      await registerPasskey(challengeUrl, createUrl, generateDeviceLabel());
    } catch (error) {
      alert('Failed to set up passkey: ' + error.message);
      setupBtn.disabled = false;
      setupBtn.innerHTML = '<i class="fa fa-key mr-2"></i> Set up';
    }
  });

  // "Not now" button: dismiss and remember for 30 days
  if (dismissBtn) {
    dismissBtn.addEventListener('click', function () {
      setCookie('passkey_prompt_dismissed', '1', 30);
      jQuery('#passkeyPromptModal').modal('hide');
    });
  }

  // Also set cookie when modal is closed via X button or backdrop click
  jQuery('#passkeyPromptModal').on('hidden.bs.modal', function () {
    setCookie('passkey_prompt_dismissed', '1', 30);
  });
}

// Initialize passkey functionality on page load
function initializePasskeys() {
  // Initialize passkey sign-in button
  const passkeyButton = document.getElementById('passkey-sign-in-btn');
  if (passkeyButton) {
    if (window.PublicKeyCredential) {
      const challengeUrl = passkeyButton.dataset.challengeUrl;
      const sessionUrl = passkeyButton.dataset.sessionUrl;
      const afterSignInUrl = passkeyButton.dataset.afterSignInUrl;

      if (challengeUrl && sessionUrl && afterSignInUrl) {
        if (!passkeyButton.dataset.listenerAttached) {
          passkeyButton.dataset.listenerAttached = 'true';
          passkeyButton.addEventListener('click', async function (e) {
            e.preventDefault();
            e.stopPropagation();

            passkeyButton.disabled = true;
            const originalText = passkeyButton.textContent;
            passkeyButton.textContent = 'Signing in...';

            try {
              await authenticateWithPasskey(challengeUrl, sessionUrl, afterSignInUrl);
            } catch (error) {
              alert('Failed to sign in with passkey: ' + error.message);
              passkeyButton.disabled = false;
              passkeyButton.textContent = originalText;
            }
          });
        }
      }
    } else {
      passkeyButton.style.display = 'none';
    }
  }

  // Initialize passkey registration button
  const registerBtn = document.getElementById('register-passkey-btn');
  if (registerBtn) {
    const challengeUrl = registerBtn.dataset.challengeUrl;
    const createUrl = registerBtn.dataset.createUrl;

    if (challengeUrl && createUrl) {
      initializePasskeyRegistration(null, challengeUrl, createUrl);
    }
  }

  // Show passkey registration prompt if applicable
  initializePasskeyPrompt();
}

document.addEventListener('DOMContentLoaded', function () {
  initializePasskeys();
});

document.addEventListener('turbo:load', function () {
  initializePasskeys();
});
