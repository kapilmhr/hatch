import 'package:flutter/widgets.dart';
import 'initialiser.dart';
import 'app.dart';

void main() async {
  await initialise();
  runApp(const MyApp());
}
