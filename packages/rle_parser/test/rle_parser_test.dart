import 'package:flutter_test/flutter_test.dart';
import 'package:rle_parser/src/rle_decoder.dart';

import 'package:rle_parser/src/rle_encoder.dart';
import 'package:rle_parser/src/rle_to_decimal_list.dart';

void main() {
  group('RLE Parser', () {
    test('Basic Encoding', () {
      expect(rleEncode('AAABBBCCDAA'), 'A3B3C2D1A2');
      expect(rleEncode(''), '');
      expect(rleEncode('A'), 'A1');
    });

    test('Basic Decoding', () {
      expect(rleDecode('A3B3C'), 'ABBBCCC');
      expect(rleDecode(''), '');
      expect(rleDecode('A1'), 'A');
    });

    test('parseRLE Cases', () {
      final result = parseRLE(r'2b2o$b2obo');
      expect(result.length, 2);
      expect(result.first, "bboo");
      expect(result.last, "boobo");
    });

    test(
      "rleToValue ..",
      () {
        expect(rleToValue<int>("A3B3C", valueMap: {"A": 0, "B": 1, "C": 3}), [0, 1, 1, 1, 3, 3, 3]);
        expect(rleToValue<int>("ABC", valueMap: {"A": 0, "B": 1, "C": 3}), [0, 1, 3]);
      },
    );
  });
}
