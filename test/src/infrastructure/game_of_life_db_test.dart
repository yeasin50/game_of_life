import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/src/domain/cell_pattern.dart';
import 'package:game_of_life/src/domain/domain.dart';
import 'package:game_of_life/src/infrastructure/game_of_life_db.dart';

void main() {
  test('game of life db ...', () async {
    final gof = GameOfLifeDataBase();
    final cellP1 = GameOfLifeDataBase.fromDigit([
      [0, 0, 0, 0, 0], //
      [0, 0, 1, 0, 0], //
      [0, 1, 1, 0, 0], //
      [0, 0, 1, 1, 0], //
      [0, 0, 0, 0, 0], //
    ]);
  });
}

bool _updateLife({
  required List<List<GridData>> grids,
  required GridData c,
}) {
  bool isTopLeftAlive = () {
    int cy = c.y == 0 ? grids.length - 1 : c.y - 1;
    int cx = c.x == 0 ? grids[c.y].length - 1 : c.x - 1;
    return grids[cy][cx].isAlive;
  }();

  bool isTopAlive = () {
    int cy = c.y == 0 ? grids.length - 1 : c.y - 1;
    return grids[cy][c.x].isAlive;
  }();

  bool isTopRightAlive = () {
    int cy = c.y == 0 ? grids.length - 1 : c.y - 1;
    int cx = c.x == grids[c.y].length - 1 ? 0 : c.x + 1;
    return grids[cy][cx].isAlive;
  }();

  bool isRightAlive = () {
    int cx = c.x == grids[c.y].length - 1 ? 0 : c.x + 1;
    return grids[c.y][cx].isAlive;
  }();

  bool isBottomRightAlive = () {
    int cy = c.y == grids.length - 1 ? 0 : c.y + 1;
    int cx = c.x == grids[c.y].length - 1 ? 0 : c.x + 1;
    return grids[cy][cx].isAlive;
  }();

  bool isBottomAlive = () {
    int cy = c.y == grids.length - 1 ? 0 : c.y + 1;
    return grids[cy][c.x].isAlive;
  }();

  bool isBottomLeftAlive = () {
    int cy = c.y == grids.length - 1 ? 0 : c.y + 1;
    int cx = c.x == 0 ? grids[c.y].length - 1 : c.x - 1;
    return grids[cy][cx].isAlive;
  }();

  bool isLeftAlive = () {
    int cx = c.x == 0 ? grids[c.y].length - 1 : c.x - 1;
    return grids[c.y][cx].isAlive;
  }();

  final surroundLifeCount = [
    isTopLeftAlive,
    isTopAlive,
    isTopRightAlive,
    isRightAlive,
    isBottomLeftAlive,
    isBottomAlive,
    isBottomRightAlive,
    isLeftAlive
  ];

  print(surroundLifeCount.where((e) => e).length);

  ///! Am I doing something wrong here?
  return switch (surroundLifeCount.where((e) => e).length) {
    3 => true,
    2 => c.isAlive,
    < 2 => false,
    > 3 => false,
    _ => false,
  };
}
