import 'domain.dart';

///Gosper glider gun
///!https://en.wikipedia.org/wiki/Gun_(cellular_automaton)#/media/File:Game_of_life_glider_gun.svg
///
class GosperGliderGun implements CellPattern {
  @override
  List<List<double>> get pattern {
    List<List<int>> result = [];
    // [5x1], [3x34]
    final bloc = [
      [1, 1],
      [1, 1],
    ];

    result = CellPattern.mergeDigit((bloc, 5, 1), (bloc, 3, 35));

    ///[3x13]
    final midFL = [
      [0, 0, 1, 1, 0, 0, 0, 0],
      [0, 1, 0, 0, 0, 1, 0, 0],
      [1, 0, 0, 0, 0, 0, 1, 0],
      [1, 0, 0, 0, 1, 0, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0, 1, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 0],
    ];

    result = CellPattern.mergeDigit((result, 0, 0), (midFL, 3, 11));

    /// [3x21]
    final midRP = [
      [0, 0, 0, 0, 1],
      [0, 0, 1, 0, 1],
      [1, 1, 0, 0, 0],
      [1, 1, 0, 0, 0],
      [1, 1, 0, 0, 0],
      [0, 0, 1, 0, 1],
      [0, 0, 0, 0, 1],
    ];

    result = CellPattern.mergeDigit((result, 0, 0), (midRP, 1, 21));

    final value = result.map((e) => e.map((e) => e.toDouble()).toList()).toList();
    return value;
  }

  @override
  List<GridData> get data {
    return CellPattern.fromDigit(pattern).expand((element) => element).toList();
  }

  @override
  String get name => "Gosper glider gun";

  @override
  (int, int) get minSpace => (30, 30);

  @override
  bool? get clip => true;
}
