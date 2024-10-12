import 'dart:typed_data';
import 'dart:ui' as ui;

import 'domain/cell_pattern.dart';

Future<ui.Image> createFrameBuffer(int width, int height) async {
  const bytesPerPixel = 4;
  final buffer = Uint8List(width * height * bytesPerPixel);

  final pattern = FiveCellPattern();
  final (startY, startX) = ((height / 2) - pattern.minSpace.$1, (width / 2) - pattern.minSpace.$2);
  final (endY, endX) = (startY + pattern.minSpace.$1 - 1, startX + pattern.minSpace.$2 - 1);

  final patternDigits = pattern.pattern;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final offset = ((y * width) + x) * bytesPerPixel;

      bool isLiveCell = () {
        bool isInBound = y >= startY && y < endY && x >= startX && x < endX;
        if (!isInBound) return false;

        final dy = y - startY.toInt();
        final dx = x - startX.toInt();

        return patternDigits[dy][dx] > .5;
      }();

      if (isLiveCell) {
        buffer[offset] = 0; // Red channel
        buffer[offset + 1] = 0; // Green channel
        buffer[offset + 2] = 0; // Blue channel
        buffer[offset + 3] = 255; // Alpha (fully opaque)
      } else {
        // Set this cell to white
        buffer[offset] = 255; // Red channel
        buffer[offset + 1] = 255; // Green channel
        buffer[offset + 2] = 255; // Blue channel
        buffer[offset + 3] = 255; // Alpha (fully opaque)
      }
    }
  }
  final immutable = await ui.ImmutableBuffer.fromUint8List(buffer);
  final descriptor = ui.ImageDescriptor.raw(
    immutable,
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec(
    targetWidth: width,
    targetHeight: height,
  );
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
