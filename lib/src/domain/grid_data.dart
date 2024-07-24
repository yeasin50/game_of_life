import 'package:flutter/material.dart';
import 'dart:math' as math;

class GridData {
  const GridData({
    required this.x,
    required this.y,
    this.life = 1.0,
    this.generation = 1,
  }) : assert(life >= 0 && life <= 1);

  final int x;
  final int y;

  /// 0--1, where 0 is death, 1 is life
  final double life;
  final int generation;

  @override
  String toString() => '$generation';

  GridData copyWith({
    int? x,
    int? y,
    double? life,
    int? generation,
  }) {
    return GridData(
      x: x ?? this.x,
      y: y ?? this.y,
      life: life ?? this.life,
      generation: generation ?? this.generation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GridData &&
        other.x == x &&
        other.y == y &&
        other.life == life;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ life.hashCode;
}

extension GridExt on GridData {
  bool get isAlive => life >= .5;

  Color get color {
    return switch (life) {
      0 => Colors.white,
      _ => Colors.green
      // Color.lerp(Colors.transparent, Colors.green, life)!
          .withOpacity(math.min((generation + .1) / 10, 1))
    };
  }
}
