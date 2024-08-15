import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_of_life/src/domain/game_of_life_db.dart';

import 'grid_data.dart';

///* If the cell is alive,
///** then it stays alive if it has either 2 or 3 live neighbors
///
///* If the cell is dead,
///** then it springs to life only in the case that it has 3 live neighbors
///
class GameOfLifeEngine extends ChangeNotifier {
  final GameOfLifeDataBase database = GameOfLifeDataBase();

  ///  [y->[x,x,x..],y->[x..],]
  List<List<GridData>> get data => [...database.grids];

  int get totalCell => data.fold(0, (previousValue, element) => previousValue + element.length);
  bool get isReady => data.isNotEmpty;

  Duration _generationGap = const Duration(milliseconds: 250);
  Duration get generationGap => _generationGap;
  Timer? _timer;

  Future<void> init({
    int numberOfRows = 50,
    int numberOfCol = 50,
    Duration generationGap = const Duration(milliseconds: 250),
  }) async {
    _generationGap = generationGap;

    await database.init(numberOfCol: numberOfCol, numberOfRows: numberOfRows);
    notifyListeners();
  }

  void clear() {
    _timer?.cancel();
    _timer = null;
    database.dispose();
    _generationGap = const Duration(seconds: 1);
    notifyListeners();
  }

  void nextGeneration() {
    database.nextGeneration();
    notifyListeners();
  }

  /// if [delay] is null, it will be default value of [generationGap]
  void startPeriodicGeneration({Duration? delay}) {
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(delay ?? generationGap, (t) {
      nextGeneration();
    });
  }

  void stopPeriodicGeneration() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }
}
