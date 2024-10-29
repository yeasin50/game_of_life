import 'dart:ui';

import 'package:flutter/material.dart';

import 'infrastructure/game_provider.dart';
import 'presentation/game_setup/setup_page.dart';

class GameOfLifeApp extends StatefulWidget {
  const GameOfLifeApp({super.key});

  @override
  State<GameOfLifeApp> createState() => _GameOfLifeAppState();
}

class _GameOfLifeAppState extends State<GameOfLifeApp> {
  late final gameFutureProvider = GameProvider.init();

  @override
  void initState() {
    super.initState();
  }

  final theme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.grey.shade900,
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
        minimumSize: const Size(150, 50),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameProvider>(
      future: gameFutureProvider,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Theme(
            data: theme,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: Text("Game of Life..."),
            ),
          );
        }
        return GameOfLifeInheritedWidget(
          provider: snapshot.data!,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            darkTheme: theme,
            scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
              PointerDeviceKind.mouse,
            }),
            home: const GameBoardSetupPage(),
          ),
        );
      },
    );
  }
}
