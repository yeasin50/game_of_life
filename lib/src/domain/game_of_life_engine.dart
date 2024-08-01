import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'grid_data.dart';

///* If the cell is alive,
///** then it stays alive if it has either 2 or 3 live neighbors
///
///* If the cell is dead,
///** then it springs to life only in the case that it has 3 live neighbors
///
class GameOfLifeEngine {
  ///  [y->[x,x,x..],y->[x..],]
  final List<List<GridData>> _data = [];
  List<List<GridData>> get data => [..._data];

  int get totalCell =>
      data.fold(0, (previousValue, element) => previousValue + element.length);

  Future<void> init({int numberOfRows = 50, int numberOfCol = 50}) async {
    _data.clear();

    final params = [numberOfRows, numberOfCol];
    final result = await compute(_init, params);

    _data.addAll(result);
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

  void dispose() {
    _data.clear();
  }

  void next() {
    for (int y = 0; y < _data.length; y++) {
      for (int x = 0; x < _data[y].length; x++) {
        final cItem = _data[y][x];
        final newLife = _updateLife(cItem);
        _data[y][x] = cItem.copyWith(
          life: newLife ? 1 : 0,
          generation: newLife ? _data[y][x].generation + 1 : 0,
        );
      }
    }
  }

  GridData? _topLeftItem(int x, int y) {
    int cy = y == 0 ? _data.length - 1 : y - 1;
    int cx = x == 0 ? _data[y].length - 1 : x - 1;
    return _data[cy][cx];
  }

  GridData? _topItem(int x, int y) {
    int cy = y == 0 ? _data.length - 1 : y - 1;
    return _data[cy][x];
  }

  GridData? _topRightItem(int x, int y) {
    int cy = y == 0 ? _data.length - 1 : y - 1;
    int cx = x == _data[y].length - 1 ? 0 : x + 1;
    return _data[cy][cx];
  }

  GridData? _rightItem(int x, int y) {
    int cx = x == _data[y].length - 1 ? 0 : x + 1;
    return _data[y][cx];
  }

  GridData? _bottomRightItem(int x, int y) {
    int cy = y == data.length - 1 ? 0 : y + 1;
    int cx = x == _data[y].length - 1 ? 0 : x + 1;
    return _data[cy][cx];
  }

  GridData? _bottomItem(int x, int y) {
    if (data.isEmpty) return throw "no data";
    int cy = y == data.length - 1 ? 0 : y + 1;

    return _data[cy][x];
  }

  GridData? _bottomLeftItem(int x, int y) {
    int cy = y == data.length - 1 ? 0 : y + 1;
    int cx = x == 0 ? _data[y].length - 1 : x - 1;
    return _data[cy][cx];
  }

  GridData? _leftItem(int x, int y) {
    int cx = x == 0 ? _data[y].length - 1 : x - 1;
    return _data[y][cx];
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

    if (c.isAlive && //
        (surroundLifeCount == 2 || surroundLifeCount == 3)) {
      return c.isAlive;
    } else if (c.isAlive == false && surroundLifeCount == 3) {
      return true;
    } else {
      return false;
    }
  }
}
