import 'dart:async';

import 'package:game_of_life/src/infrastructure/game_config.dart';

import 'game_of_life_db.dart';

import '../domain/grid_data.dart';

/// Default generation gap is 250 milliseconds
const _defaultGenerationDelay = Duration(milliseconds: 250);

class GOFState {
  const GOFState(this.data, this.generation, [this.isLoading = false]);

  const GOFState.empty() : this(const [], 0, true);

  final List<List<GridData>> data;
  final int generation;
  final bool isLoading;
}

class GameOfLifeEngine {
  GameOfLifeEngine({required this.cellDB});
  final GameOfLifeDataBase cellDB;

  late GOFState _gofState;

  GOFState get gofState => _gofState;

  late StreamController<GOFState> _dataController;
  Stream<GOFState> get dataStream => _dataController.stream;

  Duration? _generationGap;
  Duration get generationGap => _generationGap ?? _defaultGenerationDelay;
  Timer? _timer;

  Future<void> init({required GameConfig config}) async {
    _generationGap = config.generationGap;
    _gofState = const GOFState.empty();

    _dataController = StreamController<GOFState>.broadcast(
      onListen: () => _dataController.add(_gofState),
    );

    final grids = await cellDB.init(
      numberOfCol: config.numberOfCol,
      numberOfRows: config.numberOfRows,
    );

    _gofState = GOFState(grids, 0);
    _dataController.add(_gofState);
  }

  void replaceData(List<List<GridData>> data) {
    _gofState = GOFState(data, 0);
    _dataController.add(_gofState);
  }

  Future<void> dispose() async {
    _gofState = const GOFState.empty();
    _timer?.cancel();
    _timer = null;
    _generationGap = null;
    await _dataController.close();
  }

  Future<void> nextGeneration() async {
    final result = await cellDB.nextGeneration(_gofState.data);
    _gofState = GOFState(result, _gofState.generation + 1);
    _dataController.add(_gofState);
  }

  /// if [delay] is null, it will be default value of [generationGap]
  void startPeriodicGeneration({Duration? delay}) {
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(delay ?? generationGap, (t) async {
      await nextGeneration();
      //todo: check if pattern has been locked, like repeat the same pattern
      // if so cancel the timer
    });
  }

  void stopPeriodicGeneration() {
    _timer?.cancel();
    _timer = null;
  }
}
