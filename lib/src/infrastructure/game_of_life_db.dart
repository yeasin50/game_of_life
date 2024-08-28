import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/grid_data.dart';

class GOFState {
  const GOFState(this.data, this.generation, [this.isLoading = false]);

  const GOFState.empty() : this(const [], 0, true);

  final List<List<GridData>> data;
  final int generation;
  final bool isLoading;

  GOFState copyWith({
    List<List<GridData>>? data,
    int? generation,
    bool? isLoading,
  }) {
    return GOFState(
      data ?? this.data,
      generation ?? this.generation,
      isLoading ?? this.isLoading,
    );
  }
}

class GameStateValueNotifier<GOFState> extends ValueNotifier<GOFState> {
  GameStateValueNotifier(super.state);

  void update(GOFState state) {
    value = state;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

///* If the cell is alive,
///** then it stays alive if it has either 2 or 3 live neighbors
///
///* If the cell is dead,
///** then it springs to life only in the case that it has 3 live neighbors
///
class GameOfLifeDataBase {
  //hu what can I call it, just a class -_xD

  /// [y->[x,x,x..],y->[x..]]
  Future<List<List<GridData>>> init({
    int numberOfRows = 50,
    int numberOfCol = 50,
    bool? cellInitialState,
  }) async {
    final params = [numberOfRows, numberOfCol, cellInitialState];
    final result = await compute(_init, params);

    return result;
  }

  Future<List<List<GridData>>> _init(List data) async {
    final rand = math.Random();

    int heightCount = data[0] as int;
    int widthCount = data[1] as int;
    bool? cellInitialState = data[2] as bool?;

    List<List<GridData>> gridData = [];
    for (int y = 0; y < heightCount; y++) {
      final rows = <GridData>[];
      for (int x = 0; x < widthCount; x++) {
        final life = rand.nextBool();
        final item = GridData(
          x: x,
          y: y,
          life: cellInitialState ?? life ? 1 : 0,
          generation: cellInitialState ?? life ? 1 : 0,
        );
        rows.add(item);
      }
      gridData.add(rows);
    }

    return gridData;
  }

  ///return should die, live, none=die🤔

  bool _updateLife({
    required List<List<GridData>> grids,
    required GridData c,
  }) {
    GridData? _topLeftItem(int x, int y) {
      int cy = y == 0 ? grids.length - 1 : y - 1;
      int cx = x == 0 ? grids[y].length - 1 : x - 1;
      return grids[cy][cx];
    }

    GridData? _topItem(int x, int y) {
      int cy = y == 0 ? grids.length - 1 : y - 1;
      return grids[cy][x];
    }

    GridData? _topRightItem(int x, int y) {
      int cy = y == 0 ? grids.length - 1 : y - 1;
      int cx = x == grids[y].length - 1 ? 0 : x + 1;
      return grids[cy][cx];
    }

    GridData? _rightItem(int x, int y) {
      int cx = x == grids[y].length - 1 ? 0 : x + 1;
      return grids[y][cx];
    }

    GridData? _bottomRightItem(int x, int y) {
      int cy = y == grids.length - 1 ? 0 : y + 1;
      int cx = x == grids[y].length - 1 ? 0 : x + 1;
      return grids[cy][cx];
    }

    GridData? _bottomItem(int x, int y) {
      if (grids.isEmpty) return throw "no data";
      int cy = y == grids.length - 1 ? 0 : y + 1;

      return grids[cy][x];
    }

    GridData? _bottomLeftItem(int x, int y) {
      int cy = y == grids.length - 1 ? 0 : y + 1;
      int cx = x == 0 ? grids[y].length - 1 : x - 1;
      return grids[cy][cx];
    }

    GridData? _leftItem(int x, int y) {
      int cx = x == 0 ? grids[y].length - 1 : x - 1;
      return grids[y][cx];
    }

    bool isTopLeftAlive = _topLeftItem(c.x, c.y)!.isAlive;
    bool isTopAlive = _topItem(c.x, c.y)!.isAlive;
    bool isTopRightAlive = _topRightItem(c.x, c.y)!.isAlive;
    bool isRightAlive = _rightItem(c.x, c.y)!.isAlive;
    bool isBottomRightAlive = _bottomRightItem(c.x, c.y)!.isAlive;
    bool isBottomAlive = _bottomItem(c.x, c.y)!.isAlive;
    bool isBottomLeftAlive = _bottomLeftItem(c.x, c.y)!.isAlive;
    bool isLeftAlive = _leftItem(c.x, c.y)!.isAlive;

    final surroundLifeCount = [
      isTopLeftAlive,
      isTopAlive,
      isTopRightAlive,
      isRightAlive,
      isBottomLeftAlive,
      isBottomAlive,
      isBottomRightAlive,
      isLeftAlive
    ].where((e) => e).length;

    if (c.isAlive && (surroundLifeCount < 2)) {
      return false;
    }
    if (c.isAlive && (surroundLifeCount == 2 || surroundLifeCount == 3)) {
      return true;
    }
    if (c.isAlive && (surroundLifeCount > 3)) {
      return false;
    }
    if (!c.isAlive && (surroundLifeCount == 3)) {
      return true;
    }
    return false;
  }

  // Do I need to operate on isolate here?
  List<List<GridData>> _nextGeneration(List<List<GridData>> grid) {
    final currentState = [...grid];
    for (int y = 0; y < currentState.length; y++) {
      for (int x = 0; x < currentState[y].length; x++) {
        final currentItem = currentState[y][x];
        final newLife = _updateLife(c: currentItem, grids: currentState);
        currentState[y][x] = currentItem.copyWith(
          life: newLife ? 1 : 0,
          generation: newLife ? currentState[y][x].generation + 1 : 0,
        );
      }
    }
    return currentState;
  }

  Future<List<List<GridData>>> nextGeneration(List<List<GridData>> grid) async {
    final result = await compute(_nextGeneration, grid);
    return result;
  }
}
