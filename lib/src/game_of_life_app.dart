import 'package:flutter/material.dart';
import 'package:so_help/src/domain/game_of_life_engine.dart';
import 'package:so_help/src/presentation/gof_life_page.dart';

/// if node has less than two neighbor it dies
/// if node is sounded by 3 neighbor it bring alive
/// if node has
class GameOfLifeApp extends StatelessWidget {
  const GameOfLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GOFPage(
        engine: GameOfLifeEngine(),
      ),
    );
  }
}
