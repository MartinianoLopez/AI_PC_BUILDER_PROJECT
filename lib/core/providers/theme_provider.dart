import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = true;

  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
