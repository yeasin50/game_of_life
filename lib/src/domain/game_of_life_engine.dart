import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'grid_data.dart';

class GameOfLifeEngine {
  final List<GridData> _data = [];
  List<GridData> get data => [..._data];

  double _maxItemSize = 1;
  double get maxItemSize => _maxItemSize;

  int get nbOfCols => data.isEmpty ? 0 : data.last.x;
  int get nbOfRows => data.isEmpty ? 0 : data.last.y;

  int? widthCount, heightCount;

  void init({required Size size, double itemSize = 100}) {
    _maxItemSize = itemSize;
    final rand = math.Random();
    widthCount ??= size.width ~/ itemSize;
    heightCount ??= size.height ~/ itemSize;

    _data.clear();
    for (int i = 0; i < heightCount!; i++) {
      for (int j = 0; j < widthCount!; j++) {
        final item = GridData(
          x: i,
          y: j,
          life: rand.nextDouble() > .5 ? 1 : 0,
        );
        _data.add(item);
      }
    }
  }

  void dispose() {
    _data.clear();
    _maxItemSize = 1;
  }

  void next() {
    for (int i = 0; i < _data.length; i++) {
      if (_data.elementAt(i).isAlive) continue;
      final newLife = updateLife(_data.elementAt(i).copyWith());

      if (newLife != _data.elementAt(i).isAlive) {
        _data[i] = _data[i].copyWith(life: newLife ? 1 : 0);
      }
    }
  }

  ///return should die, live, none=die🤔

  bool updateLife(GridData c) {
    // return 0;
    int cx = c.x * widthCount!;
    int cy = c.y;

    const outBoundValue = true;

    bool isTopAlive =
        cy == 0 ? outBoundValue : data.elementAt(cx + cy - 1).isAlive;
    bool isBottomAlive = cy >= nbOfRows - 2
        ? outBoundValue
        : data.elementAt(cx + cy + 1).isAlive;
    bool isLeftAlive =
        cx == 0 ? outBoundValue : data.elementAt(cx - 1 + c.y).isAlive;
    bool isRightAlive = cx >= nbOfCols - 2
        ? outBoundValue
        : data.elementAt(cx + 1 + c.y).isAlive;

    final surroundLifeCount = [
      isTopAlive,
      isBottomAlive,
      isRightAlive,
      isLeftAlive
    ].where((e) => e == true).length;

    return switch (surroundLifeCount) {
      3 => true,
      _ => false,
    };
  }
}
