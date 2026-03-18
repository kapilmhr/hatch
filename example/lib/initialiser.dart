import 'package:flutter/widgets.dart';

/// All shared SDK initialisation lives here.
/// Both main.dart and main_dev.dart call this.
/// Add new SDKs here — both entry points get them automatically.
Future<void> initialise() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add Firebase.initializeApp(), notifications, deep links etc. here
}
