library rle_parser;

import 'dart:developer';

/// Encodes a string using Run-Length Encoding.
String rleEncode(String input) {
  if (input.isEmpty) return "";

  final StringBuffer result = StringBuffer();
  int count = 1;

  for (int i = 1; i < input.length; i++) {
    if (input[i] == input[i - 1]) {
      count++;
    } else {
      result.write('${input[i - 1]}$count');
      count = 1;
    }
  }

  // Append the last run
  result.write('${input[input.length - 1]}$count');
  if (result.length > input.length) {
    log("negative compression"); 
  }
  return result.toString();
}
