import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../domain/cell_pattern.dart';

const gridDimension = Deprecated("image size should depend on grid dimension rather the size of the canvas");

/// Used to feed the shader.
Future<ui.Image> cellPatternToImage({
  @gridDimension required int width,
  @gridDimension required int height,
  required ShaderCellPattern pattern,
  @gridDimension required int rows,
  @gridDimension required int cols,
  required int gridDimension,
}) async {
  const bytesPerPixel = 4;
  final buffer = Uint8List(width * height * bytesPerPixel);

  final patternDigits = pattern.cellData;

  final patternHeight = patternDigits.length;
  final patternWidth = patternDigits[0].length;

  // Step 1: Determine the size of the grid cells (ensure square cells)
  final cellWidth = (width / cols).floor();
  final cellHeight = (height / rows).floor();
  final squareCellSize = cellWidth < cellHeight ? cellWidth : cellHeight; // Ensure square cells

  // Add a small gap (grid line thickness) between cells
  final gridLineThickness = 1;
  final effectiveCellSize = squareCellSize - gridLineThickness;

  // Step 2: Calculate the starting point to center the pattern on the grid
  final startY = ((height / 2) - (patternHeight * squareCellSize / 2)).floor();
  final startX = ((width / 2) - (patternWidth * squareCellSize / 2)).floor();

  // Step 3: Fill the entire screen with black (background)
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
            if (topLeftY + dy >= height || topLeftX + dx >= width) continue;

            // Calculate the buffer offset for this pixel
            final offset = (((topLeftY + dy) * width) + (topLeftX + dx)) * bytesPerPixel;

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
