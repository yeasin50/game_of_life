import 'dart:async';

import 'package:flutter/foundation.dart';
import 'game_of_life_db.dart';

import '../domain/grid_data.dart';

class GameOfLifeEngine extends ChangeNotifier {
  GameOfLifeEngine({required this.database});
  final GameOfLifeDataBase database;

  ///  [y->[x,x,x..],y->[x..],]
  List<List<GridData>> get data => [...database.grids];

  int get totalCell => data.fold(0, (previousValue, element) => previousValue + element.length);
  bool get isReady => data.isNotEmpty;

  Duration _generationGap = const Duration(milliseconds: 250);
  Duration get generationGap => _generationGap;
  Timer? _timer;

  bool get isActive => _timer != null;

  Future<void> init({
    int numberOfRows = 50,
    int numberOfCol = 50,
    Duration generationGap = const Duration(milliseconds: 250),
    List<List<GridData>>? initData,
  }) async {
    _generationGap = generationGap;

    await database.init(
      numberOfCol: numberOfCol,
      numberOfRows: numberOfRows,
      initData: initData,
    );
    notifyListeners();
  }

  void updateCell(List<GridData> data) {
    database.updateCells(data);
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


sealed class GameState {
  const GameState();
}

