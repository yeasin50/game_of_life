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
    bool isTopLeftAlive = () {
      int cy = c.y == 0 ? grids.length - 1 : c.y - 1;
      int cx = c.x == 0 ? grids[c.y].length - 1 : c.x - 1;
      return grids[cy][cx].isAlive;
    }();

    bool isTopAlive = () {
      int cy = c.y == 0 ? grids.length - 1 : c.y - 1;
      return grids[cy][c.x].isAlive;
    }();

    bool isTopRightAlive = () {
      int cy = c.y == 0 ? grids.length - 1 : c.y - 1;
      int cx = c.x == grids[c.y].length - 1 ? 0 : c.x + 1;
      return grids[cy][cx].isAlive;
    }();

    bool isRightAlive = () {
      int cx = c.x == grids[c.y].length - 1 ? 0 : c.x + 1;
      return grids[c.y][cx].isAlive;
    }();

    bool isBottomRightAlive = () {
      int cy = c.y == grids.length - 1 ? 0 : c.y + 1;
      int cx = c.x == grids[c.y].length - 1 ? 0 : c.x + 1;
      return grids[cy][cx].isAlive;
    }();

    bool isBottomAlive = () {
      int cy = c.y == grids.length - 1 ? 0 : c.y + 1;
      return grids[cy][c.x].isAlive;
    }();

    bool isBottomLeftAlive = () {
      int cy = c.y == grids.length - 1 ? 0 : c.y + 1;
      int cx = c.x == 0 ? grids[c.y].length - 1 : c.x - 1;
      return grids[cy][cx].isAlive;
    }();

    bool isLeftAlive = () {
      int cx = c.x == 0 ? grids[c.y].length - 1 : c.x - 1;
      return grids[c.y][cx].isAlive;
    }();

    final surroundLifeCount = [
      isTopLeftAlive,
      isTopAlive,
      isTopRightAlive,
      isRightAlive,
      isBottomLeftAlive,
      isBottomAlive,
      isBottomRightAlive,
      isLeftAlive
    ];

    ///! Am I doing something wrong here?
    return switch (surroundLifeCount.where((e) => e).length) {
      3 => true,
      2 => c.isAlive,
      < 2 => false,
      > 3 => false,
      _ => false,
    };
  }

  List<List<GridData>> _nextGeneration(List<List<GridData>> grid) {
    final updateList = [
      ...grid.map((e) => [...e])
    ];

    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        final newLife = _updateLife(c: grid[y][x], grids: [...grid]);
        updateList[y][x] = grid[y][x].copyWith(
          life: newLife ? 1 : 0,
          generation: newLife ? grid[y][x].generation + 1 : 0,
        );
      }
    }

    return updateList;
  }

  Future<List<List<GridData>>> nextGeneration(List<List<GridData>> grid) async {
    final result = await compute(_nextGeneration, grid);
    return result;
  }

  static String twoDString(List<List<GridData>> grid) {
    StringBuffer sb = StringBuffer();
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        sb.write(grid[y][x].isAlive ? '1 ' : '. ');
      }
      sb.write('\n');
    }
    return sb.toString();
  }

  static List<List<GridData>> fromDigit(List<List<double>> data) {
    List<List<GridData>> grid = [];
    for (int y = 0; y < data.length; y++) {
      List<GridData> row = [];
      for (int x = 0; x < data[y].length; x++) {
        row.add(GridData(x: x, y: y, life: data[y][x]));
      }
      grid.add(row);
    }
    return grid;
  }
}
