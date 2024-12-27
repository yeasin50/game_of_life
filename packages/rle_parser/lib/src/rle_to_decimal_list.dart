library rle_parser;

import 'rle_decoder.dart';

/// [rleString] should a segment/single rle encoded or decoded string
List<T> rleToValue<T>(String rleString, {Map<String, T>? valueMap}) {
  if (rleString.isEmpty) {
    return [];
  }

  final decodedString = RegExp(r'\d').hasMatch(rleString) ? rleDecode(rleString) : rleString;

  if (valueMap != null) {
    return decodedString.split('').map((char) {
      if (valueMap.containsKey(char)) {
        return valueMap[char]!;
      } else {
        // Fallback:
        return char.codeUnits.first as T;
      }
    }).toList();
  } else {
    // No value map, return Unicode values of characters as type [T]
    return decodedString.split('').map((char) => char.codeUnits.first as T).toList();
  }
}
