import 'dart:async';

import 'package:game_of_life/src/infrastructure/infrastructure.dart';

import '../domain/domain.dart';

class GameOfLifeEngine {
  GameOfLifeEngine({required this.cellDB, required this.config});

  final GameOfLifeDataBase cellDB;

  late GameStateValueNotifier<GOFState> _gofState;
  GameStateValueNotifier<GOFState> get stateNotifier => _gofState;

  GOFState get gofState => _gofState.value;

  GameConfig config;

  Duration get generationGap => config.generationGap;
  Timer? _timer;

  bool _isReady = false;
  bool get isReady => _isReady;
  Future<void> init({
    required GameConfig config,
  }) async {
    this.config = config;
    _gofState = GameStateValueNotifier(const GOFState.empty());

    final grids = await cellDB.init(
      numberOfCol: config.numberOfCol,
      numberOfRows: config.numberOfRows,
      cellInitialState: false, //todo generate percentage ratio initial alive cell
    );
    _gofState.update(GOFState(grids, 0));
    _isReady = true;
  }

  Future<void> dispose() async {
    _gofState.value = const GOFState.empty();
    _timer?.cancel();
    _timer = null;
  }

  Future<void> killCells() async {
    final grids = await cellDB.init(
      numberOfCol: gofState.data[0].length,
      numberOfRows: gofState.data.length,
      cellInitialState: false,
    );
    _gofState.update(GOFState(grids, 0));
  }

  bool isOnPeriodicProgress = false;

  Future<void> nextGeneration() async {
    final result = await cellDB.nextGeneration(_gofState.value.data, clipBorder: config.clipOnBorder);
    _gofState.update(
      GOFState(result, _gofState.value.generation + 1, colorizeGrid: gofState.colorizeGrid),
    );
    isOnPeriodicProgress = false;
  }

  void updateState(GOFState state) {
    _gofState.update(state);
  }

  /// if [delay] is null, it will be default value of [generationGap]
  void startPeriodicGeneration() {
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(generationGap, (t) async {
      if (isOnPeriodicProgress) return;

      isOnPeriodicProgress = true;
      await nextGeneration();

      //todo: check if pattern has been locked, like repeat the same pattern
      // if so cancel the timer
    });
  }

  void stopPeriodicGeneration() {
    _timer?.cancel();
    _timer = null;
    isOnPeriodicProgress = false;
  }

  void addPattern(CellPattern pattern) async {
    final currentData = [...gofState.data];

    /// todo: check with max pattern size
    if (currentData.isEmpty || currentData.length < 5 || currentData[0].length < 5) return;

    (int y, int x) midPosition = (currentData.length ~/ 2, currentData[0].length ~/ 2);
    bool isLargeModel = pattern is GosperGliderGun || pattern is NewGun;
    final patternData = pattern.setPosition(
      x: isLargeModel ? 1 : midPosition.$2,
      y: isLargeModel ? 1 : midPosition.$1,
    );

    for (final c in patternData) {
      currentData[c.y][c.x] = c;
    }

    _gofState.update(GOFState(currentData, 0));
  }
}
