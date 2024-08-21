class GameConfig {
  GameConfig({
    required this.numberOfCol,
    required this.numberOfRows,
    required this.generationGap,
  });

  //I was thinking does it makes more sense to have immutable class
  int numberOfCol;
  int numberOfRows;
  Duration generationGap;

  bool get isValid => numberOfCol > 0 && numberOfRows > 0 && generationGap.inMilliseconds > 0;
}
