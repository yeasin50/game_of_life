import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import '../infrastructure/game_provider.dart';
import '../presentation/game_setup/setup_page.dart';

/// John Conway's Game of Life
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

  @override
  Widget build(BuildContext context) {
    final themeData = AppTheme.theme(Theme.of(context).textTheme);
    return FutureBuilder<GameProvider>(
      future: gameFutureProvider,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Theme(
            data: themeData,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: Text("Game of Life..."),
            ),
          );
        }
        return GameOfLifeInheritedWidget(
          provider: snapshot.requireData,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            darkTheme: themeData,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse},
            ),
            home: const GameBoardSetupPage(),
          ),
        );
      },
    );
  }
}
