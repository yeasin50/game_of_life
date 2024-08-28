import 'domain.dart';

abstract class CellPattern {
  List<GridData> data(int midX, int midY);
  String get name;
}

class FiveCellPattern implements CellPattern {
  @override
  List<GridData> data(int midX, int midY) {
    return [
      GridData(x: midX, y: midY, life: 1),
      GridData(x: midX - 1, y: midY, life: 1),
      GridData(x: midX, y: midY - 1, life: 1),
      GridData(x: midX, y: midY + 1, life: 1),
      GridData(x: midX + 1, y: midY + 1, life: 1),
    ];
  }

  @override
  String get name => "Five Cell";
}

class GliderPattern implements CellPattern {
  //!Randomly select 6 cells
  @override
  List<GridData> data(int midX, int midY) {
    return [
      GridData(x: midX, y: midY, life: 1),
      GridData(x: midX - 1, y: midY, life: 1),
      GridData(x: midX, y: midY - 1, life: 1),
      GridData(x: midX - 1, y: midY - 1, life: 1),
      GridData(x: midX - 2, y: midY - 1, life: 1),
      GridData(x: midX - 1, y: midY - 2, life: 1),
    ];
  }

  @override
  String get name => "Glider";
}
