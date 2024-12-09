library rle_parser;

/// Decodes a Run-Length Encoded string.
String rleDecode(String input) {
  final StringBuffer result = StringBuffer();
  final RegExp exp = RegExp(r'(\d+)([a-zA-Z])|([a-zA-Z])');

  for (final match in exp.allMatches(input)) {
    if (match.group(1) != null && match.group(2) != null) {
      // Standard RLE: <number><character>
      final int count = int.parse(match.group(1)!);
      final String char = match.group(2)!;
      result.write(char * count);
    } else if (match.group(3) != null) {
      // Single character not encoded
      result.write(match.group(3)!);
    }
  }

  return result.toString();
}

/// Decodes an RLE string into a list of decoded strings, split by a delimiter.
///
/// [input] - The RLE-encoded string, with segments separated by a delimiter.
/// [splitter] - The delimiter used to split segments (default is `"$"`).
///
/// Returns a list of decoded strings.
///
/// Throws a `FormatException` if any segment is not in a valid RLE format.
List<String> parseRLE(String input, [dynamic splitter = r'$']) {
  if (input.isEmpty) return [];

  if (splitter is! String && splitter is! num) {
    throw ArgumentError("Splitter should be a string or number");
  }

  // Split the input into segments using the splitter
  final segments = input.split(splitter.toString());

  return segments.map((segment) {
    try {
      return rleDecode(segment);
    } catch (e) {
      throw FormatException("Invalid RLE format in segment: '$segment'");
    }
  }).toList();
}
