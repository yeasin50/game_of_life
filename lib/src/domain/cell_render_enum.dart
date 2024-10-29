enum GamePlaySimulateType {
  realtime,
  canvas,
  image,
  shader,
  ;

  bool get isRealTime => this == GamePlaySimulateType.realtime;
  bool get isCanvas => this == GamePlaySimulateType.canvas;
  bool get isImage => this == GamePlaySimulateType.image;
  bool get isShader => this == GamePlaySimulateType.shader;
}
