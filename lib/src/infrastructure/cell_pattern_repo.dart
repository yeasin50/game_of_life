import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rle_parser/rle_parser.dart';

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
name = Snark loop, x = 75, y = 75
75b$75b$75b$75b$75b$75b$75b$34b2o39b$34bobo38b$36bo4b2o32b$32b4ob2o2bo2bo30b$32bo2bo3bobob2o30b$35bobobobo33b$36b2obobo33b$40bo34b$75b$26b2o47b$27bo8bo38b$27bobo5b2o38b$28b2o45b$42bo32b$43bo31b$41b3o31b$75b$32bo42b$32b2o41b$31bobo4b2o22bo12b$38bo21b3o12b$39b3o17bo15b$41bo17b2o14b$75b$52bo22b$53b2o12b2o6b$52b2o14bo6b$10b2o56bob2o3b$11bo9b2o37bo5b3o2bo3b$9bo10bobo37b2o3bo3b2o4b$9b5o8bo5b2o35b2obo6b$14bo13bo22b2o15bo6b$11b3o12bobo21bobo12b3o7b$10bo15b2o22bo13bo10b$10bob2o35b2o5bo8b5o5b$8b2o3bo3b2o37bobo10bo5b$7bo2b3o5bo37b2o9bo7b$7b2obo56b2o6b$10bo14b2o48b$10b2o12b2o49b$26bo48b$75b$18b2o17bo37b$19bo17b3o35b$16b3o21bo34b$16bo22b2o4bobo27b$45b2o28b$46bo28b$75b$35b3o37b$35bo39b$36bo38b$49b2o24b$42b2o5bobo23b$42bo8bo23b$51b2o22b$75b$38bo36b$37bobob2o32b$37bobobobo31b$34b2obobo3bo2bo28b$34bo2bo2b2ob4o28b$36b2o4bo32b$42bobo30b$43b2o30b$75b$75b$75b$'''
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

  /// convert [data] to RLE;
  /// todo: remove outer unnecessary  empty cells
  ///
  Future<String> toRLE(List<List<GridData>> data) async {
    final buffer = StringBuffer();

    for (final row in data) {
      int count = 1;
      String? currentChar = row.isNotEmpty ? (row[0].isAlive ? "o" : "b") : null;

      for (int i = 1; i < row.length; i++) {
        final nextChar = row[i].isAlive ? "o" : "b";
        if (nextChar == currentChar) {
          count++;
        } else {
          buffer.write(count > 1 ? "$count$currentChar" : currentChar);
          currentChar = nextChar;
          count = 1;
        }
      }
      if (currentChar != null) {
        buffer.write(count > 1 ? "$count$currentChar" : currentChar);
      }
      buffer.write("\$"); // End-of-line marker
    }

    return '''
name = exported model, x = ${data.first.length}, y = ${data.length}
$buffer''';
  }
}
