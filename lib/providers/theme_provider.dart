import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static ThemeProvider? _themeProvider;

  late Color bodyColor = const Color.fromRGBO(31, 47, 55, 1);

  late Color fontColor = Colors.white;

  ThemeProvider.create() {}

  factory ThemeProvider() {
    return _themeProvider ??= ThemeProvider.create();
  }
}
