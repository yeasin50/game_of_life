import 'package:flutter/material.dart';

import '../../../domain/domain.dart';

extension GridExt on GridData {
  Color get color => switch (generation) {
        0 => Colors.black,
        >= 36 => Colors.white,
        _ => HSLColor.fromAHSL(1, generation * 10.0, 1, .5).toColor(),
      };
}
