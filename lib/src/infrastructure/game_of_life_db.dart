import 'package:flutter/foundation.dart';

import '../domain/grid_data.dart';

import 'dart:math' as math;

///* If the cell is alive,
///** then it stays alive if it has either 2 or 3 live neighbors
///
///* If the cell is dead,
///** then it springs to life only in the case that it has 3 live neighbors
///
class GameOfLifeDataBase {
  /// [y->[x,x,x..],y->[x..]]
  final List<List<GridData>> _grids = [];
  List<List<GridData>> get grids => [..._grids];

  int _currentGeneration = 0;
  int get currentGeneration => _currentGeneration;

  int get totalCell => _grids.isEmpty ? 0 : grids.length * _grids.first.length;

  Future<void> init({
    int numberOfRows = 50,
    int numberOfCol = 50,
    List<List<GridData>>? initData,
  }) async {
    if (initData != null && initData.isNotEmpty) {
      _grids.addAll(initData);
      _currentGeneration = 1;
      return;
    }

    final params = [numberOfRows, numberOfCol];
    final result = await compute(_init, params);

    _grids.addAll(result.toList());
    _currentGeneration = 1;
  }

  Future<List<List<GridData>>> _init(List data) async {
    final rand = math.Random();

    int heightCount = data[0] as int;
    int widthCount = data[1] as int;

    List<List<GridData>> gridData = [];
    for (int y = 0; y < heightCount; y++) {
      final rows = <GridData>[];
      for (int x = 0; x < widthCount; x++) {
        final life = rand.nextBool();
        final item = GridData(
          x: x,
          y: y,
          life: life ? 1 : 0,
          generation: life ? 1 : 0,
        );
        rows.add(item);
      }
      gridData.add(rows);
    }

    return gridData;
  }

  void updateCells(List<GridData> cells) {
    for (final c in cells) {
      _grids[c.y][c.x] = c;
    }
  }

  void dispose() {
    _currentGeneration = 0;
    _grids.clear();
  }

  // Do I need to operate on isolate here?
  void nextGeneration() {
    _currentGeneration++;
    for (int y = 0; y < _grids.length; y++) {
      for (int x = 0; x < _grids[y].length; x++) {
        final cItem = _grids[y][x];
        final newLife = _updateLife(cItem);
        _grids[y][x] = cItem.copyWith(
          life: newLife ? 1 : 0,
          generation: newLife ? _grids[y][x].generation + 1 : 0,
        );
      }
    }
  }

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

  ///return should die, live, none=die🤔
  bool _updateLife(GridData c) {
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
}
