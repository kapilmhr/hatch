import 'package:flutter/widgets.dart';

/// All shared SDK init lives here.
/// Both main.dart and main_dev.dart call this.
/// Add new SDKs here — both entry points get them automatically.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add Firebase.initializeApp(), notifications, deep links etc. here
}
