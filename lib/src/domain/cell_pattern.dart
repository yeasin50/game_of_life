import 'domain.dart';

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

extension CellPatternExt on CellPattern {
  /// Set position from top left
  List<GridData> setPosition({required int y, required int x}) {
    return data.map((e) => e.copyWith(x: e.x + x, y: e.y + y)).toList();
  }
}
