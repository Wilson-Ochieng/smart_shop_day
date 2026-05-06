import 'package:flutter/material.dart';
import 'package:smartshop/constants/app_color.dart';

class Style {
  static ThemeData themeData({
    required bool isDarktheme, // Added type for clarity
    required BuildContext context,
  }) {
    return ThemeData(
      scaffoldBackgroundColor: isDarktheme
          ? AppColor.darkScaffoldColor
          : AppColor.lightScaffoldColor,

      cardColor: isDarktheme
          ? const Color.fromARGB(100, 78, 89, 67)
          : AppColor.lightCardColor,

      brightness: isDarktheme ? Brightness.dark : Brightness.light,

      // Corrected ElevatedButtonTheme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white, // Text/Icon color
        ),
      ),
    );
  }
}