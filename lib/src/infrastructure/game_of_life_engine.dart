import 'dart:async';

import '../domain/domain.dart';
import 'game_config.dart';
import 'game_of_life_db.dart';

/// Default generation gap is 250 milliseconds
const _defaultGenerationDelay = Duration(milliseconds: 250);

class GameOfLifeEngine {
  GameOfLifeEngine({required this.cellDB});

  final GameOfLifeDataBase cellDB;

  late GameStateValueNotifier<GOFState> _gofState;
  GameStateValueNotifier<GOFState> get stateNotifier => _gofState;

  GOFState get gofState => _gofState.value;

  Duration? _generationGap;
  Duration get generationGap => _generationGap ?? _defaultGenerationDelay;
  Timer? _timer;

  bool _isReady = false;
  bool get isReady => _isReady;
  Future<void> init({required GameConfig config}) async {
    _generationGap = config.generationGap;
    _gofState = GameStateValueNotifier(const GOFState.empty());

    final grids = await cellDB.init(
      numberOfCol: config.numberOfCol,
      numberOfRows: config.numberOfRows,
    );
    _gofState.update(GOFState(grids, 0));
    _isReady = true;
  }

  Future<void> dispose() async {
    _gofState.value = const GOFState.empty();
    _timer?.cancel();
    _timer = null;
    _generationGap = null;
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
    final result = await cellDB.nextGeneration(_gofState.value.data);
    _gofState.update(GOFState(result, _gofState.value.generation + 1));
    isOnPeriodicProgress = false;
  }

  void updateState(GOFState state) {
    _gofState.update(state);
  }

  /// if [delay] is null, it will be default value of [generationGap]
  void startPeriodicGeneration({Duration? delay}) {
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(delay ?? generationGap, (t) async {
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
    final patternData = pattern.setPosition(
      x: midPosition.$2,
      y: midPosition.$1,
    );

    for (final c in patternData) {
      currentData[c.y][c.x] = c;
    }

    _gofState.update(GOFState(currentData, 0));
  }
}
