import 'package:flutter/foundation.dart';

import 'domain.dart';

import "dart:math" as math;

extension CellPatternExt on CellPattern {
  /// Set position from top left
  List<GridData> setPosition({required int y, required int x}) {
    return data.map((e) => e.copyWith(x: e.x + x, y: e.y + y)).toList();
  }
}

abstract class CellPattern {
  List<GridData> get data;
  String get name;

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

  static String printData(List<List<GridData>> grid) {
    StringBuffer sb = StringBuffer();
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        sb.write(grid[y][x].isAlive ? '1 ' : '. ');
      }
      sb.write('\n');
    }
    return sb.toString();
  }

  static List<List<int>> mergeDigit(
    (List<List<int>> grids, int y, int x) setA,
    (List<List<int>> grids, int y, int x) setB,
  ) {
    final left = math.min(setA.$3, setB.$3);
    final top = math.min(setA.$2, setB.$2);
    final right = [
      setA.$3 + setA.$1.first.length, setA.$3, //
      setB.$3 + setB.$1.first.length, setB.$3
    ].reduce(math.max);

    final bottom = math.max(
      setA.$2 + setA.$1.length,
      setB.$2 + setB.$1.length,
    );

    List<List<int>> resultSet = [];

    for (int y = 0; y < bottom; y++) {
      final rows = <int>[];
      for (int x = 0; x < right; x++) {
        final aValue = () {
          return y >= setA.$2 &&
                  y < setA.$2 + setA.$1.length && //
                  x >= setA.$3 &&
                  x < setA.$3 + setA.$1.first.length
              ? setA.$1[y - setA.$2][x - setA.$3]
              : 0;
        }();

        final bValue = () {
          return y >= setB.$2 &&
                  y < setB.$2 + setB.$1.length && //
                  x >= setB.$3 &&
                  x < setB.$3 + setB.$1.first.length
              ? setB.$1[y - setB.$2][x - setB.$3]
              : 0;
        }();

        rows.add(aValue | bValue);
      }
      resultSet.add(rows);
    }

    return resultSet;
  }
}

class FiveCellPattern implements CellPattern {
  @override
  List<GridData> get data => CellPattern.fromDigit(
        [
          [0, 1, 0],
          [1, 1, 0],
          [0, 1, 1],
        ],
      ).expand((element) => element).toList();

  @override
  String get name => "Five Cell";
}

class GliderPattern implements CellPattern {
  @override
  List<GridData> get data => CellPattern.fromDigit(
        [
          [1, 0, 1],
          [0, 1, 1],
          [0, 1, 0],
        ],
      ).expand((e) => e).toList();

  @override
  String get name => "Glider";
}

/// LightWeightSpaceShip
class LightWeightSpaceShip implements CellPattern {
  @override
  List<GridData> get data => CellPattern.fromDigit(
        [
          [1, 0, 0, 1, 0],
          [0, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 1],
        ],
      ).expand((e) => e).toList();

  @override
  String get name => "LWSS";
}

/// LightWeightSpaceShip
class MiddleWeightSpaceShip implements CellPattern {
  @override
  List<GridData> get data => CellPattern.fromDigit(
        [
          [0, 1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0, 0],
        ],
      ).expand((element) => element).toList();

  @override
  String get name => "MWSS";
}
