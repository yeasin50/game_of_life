import 'package:flutter/material.dart';

import 'domain/game_of_life_engine.dart';
import 'presentation/gof_life_page.dart';

/*
If the cell is alive, then it stays alive if it has either 2 or 3 live neighbors
If the cell is dead, then it springs to life only in the case that it has 3 live neighbors
*/
///* Any live cell with fewer than two live neighbours dies, as if by underpopulation.
///* Any live cell with two or three live neighbours lives on to the next generation.
///* Any live cell with more than three live neighbours dies, as if by overpopulation.
///* Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
///
class GameOfLifeApp extends StatelessWidget {
  const GameOfLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GOFPage(
        engine: GameOfLifeEngine()
          ..init(
            numberOfCol: 50,
            numberOfRows: 50,
            generationGap: const Duration(milliseconds: 100),
          ),
      ),
    );
  }
}
