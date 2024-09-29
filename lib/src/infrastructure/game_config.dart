import '../domain/domain.dart';

/// Default generation gap is 250 milliseconds
const _defaultGenerationDelay = Duration(milliseconds: 250);

class GameConfig {
  GameConfig({
    required this.numberOfCol,
    required this.numberOfRows,
    this.generationGap = _defaultGenerationDelay,
    required this.clipOnBorder,
    this.gridSize,
  });

  //I was thinking does it makes more sense to have immutable class
  int numberOfCol;
  int numberOfRows;
  Duration generationGap;

  /// if [clipOnBorder] is true cell goes outside the border it will be removed
  ///
  /// if false, the borderSide will calculate the opposite cell
  bool clipOnBorder;

  /// maintain the pixel clarity `logicalSize` on simulation play ground,
  ///
  /// if we have large number of grids, reduce the value
  ///
  /// ! expensive
  double paintClarity = 1.0;

  GamePlaySimulateType simulateType = GamePlaySimulateType.realtime;

  double? gridSize;

  bool get isValid => numberOfCol > 0 && numberOfRows > 0 && generationGap.inMilliseconds > -1;
}
