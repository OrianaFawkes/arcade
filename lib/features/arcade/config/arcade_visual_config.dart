class ArcadeVisualConfig {
  final double pixelScale;

  const ArcadeVisualConfig({this.pixelScale = 1}) : assert(pixelScale > 0);

  double px(double value) => value * pixelScale;

  double get tileWidth => px(40);
  double get tileHeight => px(30);

  double get playerWidth => px(40);
  double get playerHeight => px(40);
  double get playerShadowWidth => px(24);
  double get playerShadowHeight => px(2);
  double get playerBounceHeight => px(2);

  double get wallHeight => px(70);
  double get stationHeight => px(70);
}
