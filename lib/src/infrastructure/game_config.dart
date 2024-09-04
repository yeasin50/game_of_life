class GameConfig {
  GameConfig({
    required this.numberOfCol,
    required this.numberOfRows,
    required this.generationGap,
    required this.clipOnBorder,
  });

  //I was thinking does it makes more sense to have immutable class
  int numberOfCol;
  int numberOfRows;
  Duration generationGap;

  /// if [clipOnBorder] is true cell goes outside the border it will be removed
  ///
  /// if false, the borderSide will calculate the opposite cell
  bool clipOnBorder;

  bool get isValid => numberOfCol > 0 && numberOfRows > 0 && generationGap.inMilliseconds > 0;
}
