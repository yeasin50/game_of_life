import 'domain.dart';

import "dart:math" as math;

extension CellPatternExt on CellPattern {
  /// Set position from top left
  List<GridData> setPosition({required int y, required int x}) {
    return data.map((e) => e.copyWith(x: e.x + x, y: e.y + y)).toList();
  }

  (int y, int x) get midPoint {
    return (minSpace.$1 ~/ 2, minSpace.$1 ~/ 2);
  }
}

abstract class CellPattern {
  List<GridData> get data;
  String get name;

  (int y, int x) get minSpace;

  bool? get clip;

  List<List<double>> get pattern;

  @Deprecated("use [CellPatternRepo.digitsToGridData] instead")
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

  /// if [exportMode] is true,  it can generate value that can be reuse on [fromDigit]
  /// [exportMode] is false when we like to print on console
  ///
  static String printData(List<List<GridData>> grid) {
    StringBuffer sb = StringBuffer();
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        String str;

        str = grid[y][x].isAlive ? '1 ' : '. ';

        sb.write(str);
      }

      sb.write('\n');
    }

    return "\n${sb.toString()}";
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

class ShaderCellPattern implements CellPattern {
  const ShaderCellPattern(this.cellData);

  final List<List<GridData>> cellData;

  @override
  bool? get clip => true;

  @override
  List<GridData> get data => cellData.reduce((value, element) => value + element);

  @override
  (int, int) get minSpace => (cellData.length, cellData.first.length);

  @override
  String get name => "";

  @override
  List<List<double>> get pattern => throw UnimplementedError();
}
