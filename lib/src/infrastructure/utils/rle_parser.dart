import "dart:math" as math;

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
/// FIXME: I misunderstod the pattern
Map<String, dynamic> parseRLE(String rle) {
  List<String> lines = rle.trim().split('\n').toList();

  if (lines.isEmpty) {
    throw "empty string ";
  }

  if (lines.first[0] == "#") lines.removeAt(0);
  final name = lines.first.split(",").first.trim().split("=").last;

  List<List<double>> grid = [];
  int maxX = 0;

  for (final row in lines.last.split("\$")) {
    List<String> rowData = splitRLERow(row);
    for (final char in rowData) {
      if (char.length > 1) {
        int digit = int.tryParse(char.substring(0, char.length - 2)) ?? 1;
        // final digits = List.generate(digit, (index) => char[char.length - 1] == "b" ? 0.0 : 1.0);
        grid.add([]);
        // maxX = math.max(digits.length, maxX);
      } else {
        // for single char
        grid.add(char == "b" ? [0] : [1]);
      }
    }
  }

  /// refine and fill empty cell to cover
  for (int y = 0; y < grid.length; y++) {
    int gap = (maxX - grid[y].length).abs();
    print("$y +> $gap");

    // if (gap != 0) grid[y] = [...grid[y], ...List.filled(gap, 0.0)];
  }
  return {
    "name": name,
    "min_space_x": grid.first.length,
    "min_space_y": grid.length,
    "data": grid,
  };
}

List<String> splitRLERow(String input) {
  List<String> result = [];
  int i = 0;

  while (i < input.length) {
    // Find the number part
    String numberPart = '';
    while (i < input.length && RegExp(r'\d').hasMatch(input[i])) {
      numberPart += input[i];
      i++;
    }

    if (numberPart.isNotEmpty) {
      result.add(numberPart + input[i]);
      i++;
    }

    if (i < input.length && !RegExp(r'\d').hasMatch(input[i])) {
      result.add(input[i]);
      i++;
    }
  }

  return result;
}
