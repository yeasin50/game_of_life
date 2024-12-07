import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme(TextTheme textTheme) => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey.shade900,
        canvasColor: Colors.grey.shade900,
        hintColor: Colors.white,
        primaryTextTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 50),
          ),
        ),
      );
}
