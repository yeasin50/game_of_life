import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/src/domain/entities/pattern_from_json.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test(
    "parse model",
    () async {
      final jsonString = await rootBundle.loadString('assets/json/pulsar.json');

      final cellPattern = CellPatternFromJson(jsonString);

      // Verify the properties
      expect(cellPattern.name, "Pulsar");
      expect(cellPattern.data.length, 14 * 16);
    },
  );
}
