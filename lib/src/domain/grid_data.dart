import 'package:flutter/material.dart';

class GridData {
  const GridData({
    required this.x,
    required this.y,
    this.life = 1.0,
  }) : assert(life >= 0 && life <= 1);

  final int x;
  final int y;

  /// 0--1, where 0 is death, 1 is life
  final double life;

  @override
  String toString() => '($x, $y,${life.toStringAsFixed(1)})';

  GridData copyWith({
    int? x,
    int? y,
    double? life,
  }) {
    return GridData(
      x: x ?? this.x,
      y: y ?? this.y,
      life: life ?? this.life,
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
      _ => Color.lerp(Colors.transparent, Colors.green, life)!
    };
  }
}
