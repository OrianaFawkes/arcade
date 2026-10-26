import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@JS('arcadeAnalytics.enable')
external JSBoolean _enableAnalytics(
  JSString measurementId,
  JSString allowedHostsCsv,
);

@JS('arcadeAnalytics.disable')
external void _disableAnalytics();

enum AnalyticsConsentChoice { undecided, accepted, rejected }

class AnalyticsConsentController extends ChangeNotifier {
  AnalyticsConsentController();

  static const _preferenceKey = 'analytics_consent_v1';

  static const _analyticsEnabled = bool.fromEnvironment(
    'ARCADE_ANALYTICS_ENABLED',
    defaultValue: false,
  );

  static const _measurementId = String.fromEnvironment('GA_MEASUREMENT_ID');

  static const _allowedHostsCsv = String.fromEnvironment(
    'ARCADE_ANALYTICS_ALLOWED_HOSTS',
  );

  SharedPreferences? _preferences;

  AnalyticsConsentChoice _choice = .undecided;

  bool _bridgeEnabled = false;
  bool _initialized = false;

  AnalyticsConsentChoice get choice => _choice;

  bool get analyticsAvailableHere {
    if (!_analyticsEnabled) return false;

    if (!_measurementId.startsWith('G-')) return false;

    final allowedHosts = _allowedHostsCsv
        .split(',')
        .map((host) => host.trim().toLowerCase())
        .where((host) => host.isNotEmpty);

    return allowedHosts.contains(Uri.base.host.toLowerCase());
  }

  bool get isPrivacyPage {
    final path = Uri.base.path.replaceFirst(RegExp(r'/+$'), '');
    if (path == '/privacy') return true;

    return false;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _preferences = await SharedPreferences.getInstance();

      final savedChoice = _preferences!.getString(_preferenceKey);

      _choice = switch (savedChoice) {
        'accepted' => .accepted,
        'rejected' => .rejected,
        _ => .undecided,
      };

      _initialized = true;

      if (_choice == .accepted) {
        _enableIfPermitted();
      }
    } catch (_) {
      // Fail closed: if consent cannot be read, do not enable analytics.
      _choice = .undecided;
      _bridgeEnabled = false;
      _initialized = true;
    }
  }

  Future<void> setChoice(AnalyticsConsentChoice newChoice) async {
    if (!_initialized) {
      await initialize();
    }

    // Persist the choice before enabling or disabling the browser tag.
    try {
      final preferences = _preferences ?? await SharedPreferences.getInstance();

      _preferences = preferences;

      if (newChoice == .undecided) {
        await preferences.remove(_preferenceKey);
      } else {
        await preferences.setString(
          _preferenceKey,
          newChoice == .accepted ? 'accepted' : 'rejected',
        );
      }
    } catch (_) {
      // If persistence fails, don't start collecting analytics.
      if (newChoice == .accepted) {
        return;
      }
    }

    final previousChoice = _choice;
    _choice = newChoice;
    notifyListeners();

    if (newChoice == .accepted) {
      _enableIfPermitted();
    } else if (previousChoice == .accepted && _bridgeEnabled) {
      _bridgeEnabled = false;
      _disableAnalytics();
    }
  }

  void _enableIfPermitted() {
    if (!analyticsAvailableHere) return;

    try {
      _bridgeEnabled = _enableAnalytics(
        _measurementId.toJS,
        _allowedHostsCsv.toJS,
      ).toDart;
    } catch (_) {
      // A bridge failure must never be treated as successful activation.
      _bridgeEnabled = false;
    }
  }
}

final analyticsConsentController = AnalyticsConsentController();
