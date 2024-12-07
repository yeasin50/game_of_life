import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/cell_patterns/cell_patterns.dart';
import '../domain/cell_patterns/small_patterns.dart';
import '../domain/domain.dart';
import '../domain/entities/pattern_from_json.dart';

///
/// reducing the burden on cell_pattern.dart 🥱
/// and manage Read operation
///
/// - provides the cell_patterns data
/// - able to convert from N cases
///
class CellPatternRepo {
  CellPatternRepo._();

  late List<CellPattern> _patterns; // no update state; no stream
  List<CellPattern> get patterns => _patterns;

  static Future<CellPatternRepo> create() async {
    final repo = CellPatternRepo._();
    repo._init();

    return repo;
  }

  Future<void> _init() async {
    _patterns = [];
    _patterns.addAll(_samples);

    //just crash on issue, local assets should be fixed before deploy or even push
    final data = await _getLocalAssets();
    _patterns.addAll(data);
  }

  List<String> get _assetsPatternPaths => [
        "assets/json/pulsar.json",
      ];

  Future<List<CellPattern>> _getLocalAssets() async {
    try {
      List<Future> futures = [];
      for (final patternPath in _assetsPatternPaths) {
        futures.add(rootBundle.loadString(patternPath));
      }

      final data = await Future.wait(futures);

      List<CellPatternFromJson> results = [];
      for (final r in data) {
        results.add(CellPatternFromJson(r));
      }

      return results;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// we have some  predefined hard coded models
  List<CellPattern> get _samples => [
        FiveCellPattern(),
        GliderPattern(),
        LightWeightSpaceShip(),
        MiddleWeightSpaceShip(),
        GosperGliderGun(),
        NewGun(),
        M1CellPattern(),
        M2CellPattern(),
      ];

  /// convert 2D<double> into 2D[GridData] to feed/create [CellPattern] instance
  ///
  List<List<GridData>> digitsToGridData(List<List<double>> data) {
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
}
