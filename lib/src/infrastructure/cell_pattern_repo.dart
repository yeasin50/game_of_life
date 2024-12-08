import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/cell_patterns/cell_patterns.dart';
import '../domain/cell_patterns/small_patterns.dart';
import '../domain/domain.dart';
import '../domain/entities/pattern_from_json.dart';
import 'utils/rle_parser.dart';

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
    // _patterns.addAll(await _getRLEPatterns());
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

  List<String> get _getRLE => [
        '''
#C [[ ZOOM 6 GRID COLOR GRID 192 192 192 COLOR DEADRAMP 255 220 192 COLOR ALIVE 0 0 0 COLOR ALIVERAMP 0 0 0 COLOR DEAD 192 220 255 COLOR BACKGROUND 255 255 255 GPS 10 WIDTH 937 HEIGHT 600 ]]
name = Snark loop, x = 65, y = 65, rule = B3/S23
27b2o\$27bobo\$29bo4b2o\$25b4ob2o2bo2bo\$25bo2bo3bobob2o\$28bobobobo\$29b2obobo\$33bo2\$19b2o\$20bo8bo\$20bobo5b2o\$21b2o\$35bo\$36bo\$34b3o2\$25bo\$25b2o\$24bobo4b2o22bo\$31bo21b3o\$32b3o17bo\$34bo17b2o2\$45bo\$46b2o12b2o\$45b2o14bo\$3b2o56bob2o\$4bo9b2o37bo5b3o2bo\$2bo10bobo37b2o3bo3b2o\$2b5o8bo5b2o35b2obo\$7bo13bo22b2o15bo\$4b3o12bobo21bobo12b3o\$3bo15b2o22bo13bo\$3bob2o35b2o5bo8b5o\$b2o3bo3b2o37bobo10bo\$o2b3o5bo37b2o9bo\$2obo56b2o\$3bo14b2o\$3b2o12b2o\$19bo2\$11b2o17bo\$12bo17b3o\$9b3o21bo\$9bo22b2o4bobo\$38b2o\$39bo2\$28b3o\$28bo\$29bo\$42b2o\$35b2o5bobo\$35bo8bo\$44b2o2\$31bo\$30bobob2o\$30bobobobo\$27b2obobo3bo2bo\$27bo2bo2b2ob4o\$29b2o4bo\$35bobo\$36b2o!
    '''
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
