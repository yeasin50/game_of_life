import "dart:math" as math;
import "package:rle_parser/rle_parser.dart" as rle;

///  help to parse from website data
/// ! have some incosistency  on x
///- b = dead
///- o = alive
///- Numbers specify how many times the preceding character (b or o) is repeated.
/// For example, 3o means three consecutive "alive" cells.
/// ```dart
///     const rleInput = """
/// name = example, x = 3, y = 5, rule = B3/S23
/// 2b2o\$!
// """;
//
// final result = parseRLE(rleInput);
///```
Map<String, dynamic> parseRLE(String data) {
  List<String> lines = data.trim().split('\n').toList();

  if (lines.isEmpty) {
    throw "empty string ";
  }

  if (lines.first[0] == "#") lines.removeAt(0);
  final name = lines.first.split(",").first.trim().split("=").last;

  List<List<double>> grid = [];

  int maxX = 0;
  String rleDataString = lines.last.replaceAll(r"!", "").trim();

  for (final row in rle.parseRLE(rleDataString)) {
    final rowValue = rle.rleToValue<double>(row, valueMap: {"b": 0.0, "o": 1.0});
    maxX = math.max(maxX, rowValue.length);
    grid.add(rowValue);
  }

  /// refine and fill empty cell to cover
  for (int y = 0; y < grid.length; y++) {
    int gap = (maxX - grid[y].length).abs();
    if (gap != 0) grid[y] = [...grid[y], ...List.filled(gap, 0.0)];
  }
  return {
    "name": name,
    "min_space_x": grid.first.length,
    "min_space_y": grid.length,
    "data": grid,
  };
}
