import 'dart:convert';

import 'package:game_of_life/src/domain/domain.dart';

class CellPatternFromJson implements CellPattern {
  const CellPatternFromJson._(
    this._name,
    this._data,
    this._minWidth,
    this._minHeight,
  );

  final String _name;
  final List<List<double>> _data;
  final int _minWidth;
  final int _minHeight;

  factory CellPatternFromJson._fromMap(Map<String, dynamic> map) {
    return CellPatternFromJson._(
      map['name'] ?? '',
      List.from(map["data"].map((row) => List<double>.from(row.map((e) => e.toDouble())))),
      map['min_space_x']?.toInt() ?? 100,
      map['min_space_y']?.toInt() ?? 100,
    );
  }

  factory CellPatternFromJson(String source) => CellPatternFromJson._fromMap(json.decode(source));

  @override
  bool? get clip => true;

  @override
  (int, int) get minSpace => (_minHeight, _minWidth);

  @override
  List<List<double>> get pattern => _data;

  @override
  List<GridData> get data => CellPattern.fromDigit(_data).expand((e) => e).toList();

  @override
  String get name => _name;
}
