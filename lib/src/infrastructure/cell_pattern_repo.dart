import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/cell_patterns/cell_patterns.dart';
import '../domain/cell_patterns/small_patterns.dart';
import '../domain/domain.dart';
import '../domain/entities/pattern_from_json.dart';
import 'utils/rle_pattern_parser.dart';

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
    _patterns.addAll(await _getRLEPatterns());
  }

  List<String> get _assetsPatternPaths => [
        "assets/json/pulsar.json",
        "assets/json/diehard.json",
        "assets/json/puffer_train.json",
        "assets/json/pentadecathlon.json",
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


  //FIXME: Snark loop isnt ok 
  List<String> get _getRLE => [
        r"""#C [[ ZOOM 16 GRID COLOR GRID 192 192 192 GRIDMAJOR 10 COLOR GRIDMAJOR 128 128 128 COLOR DEADRAMP 255 220 192 COLOR ALIVE 0 0 0 COLOR ALIVERAMP 0 0 0 COLOR DEAD 192 220 255 COLOR BACKGROUND 255 255 255 GPS 10 WIDTH 937 HEIGHT 600 ]]
name = Copperhead, x = 12, y = 8, rule = B3/S23
5bob2o$4bo6bo$3b2o3bo2bo$2obo5b2o$2obo5b2o$3b2o3bo2bo$4bo6bo$5bob2o!""",
        r'''
#C [[ ZOOM 6 GRID COLOR GRID 192 192 192 COLOR DEADRAMP 255 220 192 COLOR ALIVE 0 0 0 COLOR ALIVERAMP 0 0 0 COLOR DEAD 192 220 255 COLOR BACKGROUND 255 255 255 GPS 10 WIDTH 937 HEIGHT 600 ]]
name = Snark loop, x = 65, y = 65, rule = B3/S23
16b2o$16bobo$18bo4b2o$14b4ob2o2bo2bo$14bo2bobobobob2o$17bobobobo$18b2obobo$22bo2$8b2o$9bo8b2o$9bobo5bobo$10b2o7bo$19b2o3$32b2o$32bo$30bobo$30b2o3$39b2o$39bo$37bobo$37b2o$52b2o$52bobo$54bo$54b2o4$26b2o$26b2o$45bo$43b3o$42bo$42b2o4$13b2o$13b2o$2o$b2o$o4$10b2o$10b2o$33b2o$32bobo$32bo$31b2o3$22b2o$23bo7b2o$23bobo5bobo$24b2o8bo$33b2o2$18bo$17bobob2o$17bobobobo$14b2obobobobo2bo$14bo2bo2b2ob4o$16b2o4bo$22bobo$23b2o!'''
      ];

  Future<List<CellPatternFromJson>> _getRLEPatterns() async {
    try {
      List<CellPatternFromJson> results = [];
      for (final r in _getRLE) {
        results.add(CellPatternFromJson(jsonEncode(parseRLE(r))));
      }

      return results;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
