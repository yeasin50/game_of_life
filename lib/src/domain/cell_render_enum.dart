enum GamePlaySimulateType {
  realtime,
  canvas,
  image;

  bool get isRealTime => this == GamePlaySimulateType.realtime;
  bool get isCanvas => this == GamePlaySimulateType.canvas;
  bool get isImage => this == GamePlaySimulateType.image;
}
