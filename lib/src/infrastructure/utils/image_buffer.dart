import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../domain/cell_pattern.dart';

const gridDimension = Deprecated("image size should depend on grid dimension rather the size of the canvas");

/// Used to feed the shader.
Future<ui.Image> cellPatternToImage({
  required ShaderCellPattern pattern,
  required int gridDimension,
}) async {
  const bytesPerPixel = 4;

  /// *40 for clarity
  final int canvasSize = gridDimension * 40;

  final buffer = Uint8List(canvasSize * canvasSize * bytesPerPixel);

  final patternDigits = pattern.cellData;

  final patternHeight = patternDigits.length;
  final patternWidth = patternDigits[0].length;

  final squareCellSize = canvasSize / gridDimension;

  // Add a small gap (grid line thickness) between cells
  final gridLineThickness = 2;
  final effectiveCellSize = squareCellSize - gridLineThickness;

  // Step 2: Calculate the starting point to center the pattern on the grid
  final startY = ((canvasSize / 2) - (patternHeight * squareCellSize / 2)).floor();
  final startX = ((canvasSize / 2) - (patternWidth * squareCellSize / 2)).floor();

  //   Fill the entire screen with black (background)
  for (int i = 0; i < buffer.length; i += bytesPerPixel) {
    buffer[i] = 0; // Red channel (black)
    buffer[i + 1] = 0; // Green channel (black)
    buffer[i + 2] = 0; // Blue channel (black)
    buffer[i + 3] = 255; // Alpha (fully opaque)
  }

  // Step 4: Draw the pattern in the center
  for (int py = 0; py < patternHeight; py++) {
    for (int px = 0; px < patternWidth; px++) {
      // Check if this is a live cell (white) or dead cell (black)
      bool isLiveCell = patternDigits[py][px].life == 1;

      // Calculate the top-left corner of the current cell in the grid
      final topLeftY = startY + py * squareCellSize;
      final topLeftX = startX + px * squareCellSize;

      // Fill the cell with white if it's a live cell, otherwise leave it black
      if (isLiveCell) {
        for (int dy = 0; dy < effectiveCellSize; dy++) {
          for (int dx = 0; dx < effectiveCellSize; dx++) {
            // Make sure we are within the screen bounds
            if (topLeftY + dy >= canvasSize || topLeftX + dx >= canvasSize) continue;

            // Calculate the buffer offset for this pixel
            final offset = ((((topLeftY + dy) * canvasSize) + (topLeftX + dx)) * bytesPerPixel).toInt();

            // Set the pixel color to white for live cells
            buffer[offset] = 255; // Red channel (white)
            buffer[offset + 1] = 255; // Green channel (white)
            buffer[offset + 2] = 255; // Blue channel (white)
            buffer[offset + 3] = 255; // Alpha (fully opaque)
          }
        }
      }
    }
  }

  // Create the image from the buffer
  final immutable = await ui.ImmutableBuffer.fromUint8List(buffer);
  final descriptor = ui.ImageDescriptor.raw(
    immutable,
    width: canvasSize,
    height: canvasSize,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec(targetWidth: canvasSize, targetHeight: canvasSize);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
