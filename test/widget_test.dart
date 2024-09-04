// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'dart:math' as math;

List<List<int>> merge(
  (List<List<int>> grids, int y, int x) setA,
  (List<List<int>> grids, int y, int x) setB,
) {
  final left = math.min(setA.$3, setB.$3);
  final top = math.min(setA.$2, setB.$2);
  final right = math.max(
    setA.$3 + setA.$1.first.length,
    setB.$3 + setB.$1.first.length,
  );
  final bottom = math.max(
    setA.$2 + setA.$1.length,
    setB.$2 + setB.$1.length,
  );

  List<List<int>> resultSet = [];

  for (int y = 0; y < bottom; y++) {
    final rows = <int>[];
    for (int x = 0; x < right; x++) {
      final aValue = () {
        return y >= setA.$2 &&
                y < setA.$2 + setA.$1.length && //
                x >= setA.$3 &&
                x < setA.$3 + setA.$1.first.length
            ? setA.$1[y - setA.$2][x - setA.$3]
            : 0;
      }();

      // Get value from setB if it's within bounds
      final bValue = () {
        return y >= setB.$2 &&
                y < setB.$2 + setB.$1.length && //
                x >= setB.$3 &&
                x < setB.$3 + setB.$1.first.length
            ? setB.$1[y - setB.$2][x - setB.$3]
            : 0;
      }();

      rows.add(aValue | bValue);
    }
    resultSet.add(rows);
  }

  return resultSet;
}

void main() {
  test("grid auditing ", () {
    final a = [
      [1, 0],
      [0, 1],
    ];

    final b = [
      [0, 0, 1],
    ];

    final result = merge((a, 1, 0), (b, 1, 0));

    print(result);
  });
}
