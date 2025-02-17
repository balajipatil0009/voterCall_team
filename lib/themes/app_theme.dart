import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A237E); // Deep Blue
  static const secondaryColor = Color(0xFF303F9F); // Medium blue
  static const backgroundColor =
      Color(0xFFF5F7FA); // Light grey-blue background
  static const surfaceColor = Colors.white; // White surface
  static const accentColor = Color(0xFF2196F3); // Bright blue accent
  static const textColor = Color(0xFF2C3E50); // Dark blue-grey text
  static const subtitleColor = Color(0xFF607D8B); // Blue-grey

  static ThemeData lightBlueTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: textColor),
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all(surfaceColor),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
      titleSmall: TextStyle(color: subtitleColor),
    ),
  );
}
