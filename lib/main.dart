import 'package:arcade/app/analytics/analytics_consent_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:arcade/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await analyticsConsentController.initialize();

  runApp(MyApp());
}
