import 'package:flutter/material.dart';

class GameColorConfig {
  static Color genColor(int generation) {
    return switch (generation) {
      0 => Colors.black,
      >= 36 => Colors.white,
      _ => HSLColor.fromAHSL(1, generation * 10.0, 1, .5).toColor(),
    };
  }
}
