import 'domain.dart';

///! https://conwaylife.com/wiki/New_gun_1
///
class NewGun extends CellPattern {
  @override
  (int y, int x) get minSpace => (20, 49);

  @override
  List<List<double>> get pattern {
    List<List<int>> result = [];

    // [4x0], [11x0]
    final block = [
      [1, 1],
      [1, 1],
    ];

    result = CellPattern.mergeDigit((block, 4, 0), (block, 11, 0));

    // [6,13], [10,13]
    final b2block = [
      [1, 1]
    ];
    result = CellPattern.mergeDigit((result, 0, 0), (b2block, 6, 13));
    result = CellPattern.mergeDigit((result, 0, 0), (b2block, 10, 13));

    // [3,17],
    final bL2TopM = [
      [1, 0, 0],
      [1, 1, 0],
      [0, 1, 1],
      [1, 1, 0],
    ];
    result = CellPattern.mergeDigit((result, 0, 0), (bL2TopM, 3, 17));

    // [10,17],
    final bL2BM = [
      [1, 1, 0],
      [0, 1, 1],
      [1, 1, 0],
      [1, 0, 0],
    ];
    result = CellPattern.mergeDigit((result, 0, 0), (bL2BM, 10, 17));

    // [0,29],
    final bR2TM = [
      [0, 1, 1],
      [1, 0, 1],
      [1, 0, 0],
      [1, 1, 1],
    ];
    result = CellPattern.mergeDigit((result, 0, 0), (bR2TM, 0, 29));

    // [7,29],
    final bR2BM = [
      [1, 1, 1],
      [1, 0, 0],
      [1, 0, 1],
      [0, 1, 1],
    ];
    result = CellPattern.mergeDigit((result, 0, 0), (bR2BM, 7, 29));
    // [1,47],[8,47],
    final tR2B = [
      [1, 1],
      [1, 1]
    ];
    result = CellPattern.mergeDigit((result, 0, 0), (tR2B, 1, 47));
    result = CellPattern.mergeDigit((result, 0, 0), (tR2B, 8, 47));

    final value = result.map((e) => e.map((e) => e.toDouble()).toList()).toList();

    return value;
  }

  @override
  List<GridData> get data {
    return CellPattern.fromDigit(pattern).expand((element) => element).toList();
  }

  @override
  String get name => "New gun 1";

  @override
  bool? get clip => true;
}
