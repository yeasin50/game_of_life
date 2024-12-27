
import '../domain.dart';

class FiveCellPattern implements CellPattern {
  @override
  (int y, int x) get minSpace => (4, 4);
  @override
  List<List<double>> get pattern => //
      [
        [0, 1, 0],
        [1, 1, 0],
        [0, 1, 1],
      ];

  @override
  List<GridData> get data => //
      CellPattern.fromDigit(pattern).expand((e) => e).toList();

  @override
  String get name => "Five Cell";

  @override
  bool? get clip => false;
}

class GliderPattern implements CellPattern {
  @override
  (int y, int x) get minSpace => (4, 4);
  @override
  List<List<double>> get pattern => [
        [1, 0, 1],
        [0, 1, 1],
        [0, 1, 0],
      ];

  @override
  List<GridData> get data => //
      CellPattern.fromDigit(pattern).expand((e) => e).toList();

  @override
  String get name => "Glider";

  @override
  bool? get clip => false;
}

/// LightWeightSpaceShip
class LightWeightSpaceShip implements CellPattern {
  @override
  List<List<double>> get pattern => [
        [1, 0, 0, 1, 0],
        [0, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 1],
      ];
  @override
  (int y, int x) get minSpace => (6, 5);

  @override
  List<GridData> get data => //
      CellPattern.fromDigit(pattern).expand((e) => e).toList();

  @override
  String get name => "LWSS";

  @override
  bool? get clip => false;
}

/// LightWeightSpaceShip
class MiddleWeightSpaceShip implements CellPattern {
  @override
  (int y, int x) get minSpace => (7, 7);

  @override
  List<List<double>> get pattern => [
        [0, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 0],
      ];

  @override
  List<GridData> get data => //

      CellPattern.fromDigit(pattern).expand((element) => element).toList();

  @override
  String get name => "MWSS";

  @override
  bool? get clip => false;
}
