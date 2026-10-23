
(() => {
  'use strict';

  const state = {
    enabled: false,
    measurementId: null,
    script: null,
  };

  function isAllowedHost(allowedHostsCsv) {
    const allowedHosts = (allowedHostsCsv || '')
      .split(',')
      .map((host) => host.trim().toLowerCase())
      .filter(Boolean);

    return allowedHosts.includes(window.location.hostname.toLowerCase());
  }

  function enable(measurementId, allowedHostsCsv) {
    // Fail closed if production configuration is missing or malformed.
    if (!/^G-[A-Z0-9]+$/.test(measurementId || '')) {
      return false;
    }

    // A production build must also be running on an approved hostname.
    if (!isAllowedHost(allowedHostsCsv)) {
      return false;
    }

    // Avoid injecting the tag more than once.
    if (state.enabled) {
      return state.measurementId === measurementId;
    }

    if (state.script && state.measurementId !== measurementId) {
      return false;
    }

    window.dataLayer = window.dataLayer || [];
    window.gtag = function () {
      window.dataLayer.push(arguments);
    };

    window.gtag('js', new Date());
    window.gtag('config', measurementId, {
      allow_google_signals: false,
      allow_ad_personalization_signals: false,
    });

    const script = document.createElement('script');
    script.async = true;
    script.src =
      'https://www.googletagmanager.com/gtag/js?id=' +
      encodeURIComponent(measurementId);

    script.onerror = () => {
      state.enabled = false;
    };

    document.head.appendChild(script);

    state.enabled = true;
    state.measurementId = measurementId;
    state.script = script;

    return true;
  }

  function disable() {
    if (!state.enabled) return;

    state.enabled = false;

    // Reloading discards the loaded Google tag and its JavaScript context.
    // Flutter must save the user's withdrawn choice before calling this.
    window.location.reload();
  }

  window.arcadeAnalytics = Object.freeze({
    enable,
    disable,
  });
})();
