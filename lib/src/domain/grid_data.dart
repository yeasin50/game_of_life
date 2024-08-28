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
  String toString() {
    return 'GridData(x: $x, y: $y, life: $life, generation: $generation)';
  }

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

  bool get isAlive => life >= .5;
}
