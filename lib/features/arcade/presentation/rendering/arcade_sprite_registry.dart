import 'package:arcade/features/arcade/presentation/generated/arcade_tile_pixels.dart';

typedef PixelMatrix = List<List<int>>;

class ArcadeSpriteRegistry {
  ArcadeSpriteRegistry._();

  static const Map<String, PixelMatrix> sprites = {
    'floor': [
      [0],
    ],
    'floor_end_north': [
      [0],
    ],
    'floor_end_east': [
      [0],
    ],
    'floor_end_south': [
      [0],
    ],
    'floor_end_west': [
      [0],
    ],
    'floor_end_north_east': [
      [0],
    ],
    'floor_end_north_south': [
      [0],
    ],
    'floor_end_north_west': [
      [0],
    ],
    'floor_end_east_south': [
      [0],
    ],
    'floor_end_east_west': [
      [0],
    ],
    'floor_end_south_west': [
      [0],
    ],
    'floor_end_north_east_south': [
      [0],
    ],
    'floor_end_north_east_west': [
      [0],
    ],
    'floor_end_north_south_west': [
      [0],
    ],
    'floor_end_east_south_west': [
      [0],
    ],
    'floor_end_north_east_south_west': [
      [0],
    ],
    'wall': wallPixels,
    'wall_end_north': wallEndNorthPixels,
    'wall_end_east': wallEndEastPixels,
    'wall_end_south': wallEndSouthPixels,
    'wall_end_west': wallEndWestPixels,
    'wall_end_north_east': wallEndNorthEastPixels,
    'wall_end_north_south': wallEndNorthSouthPixels,
    'wall_end_north_west': wallEndNorthWestPixels,
    'wall_end_east_south': wallEndEastSouthPixels,
    'wall_end_east_west': wallEndEastWestPixels,
    'wall_end_south_west': wallEndSouthWestPixels,
    'wall_end_north_east_south': wallEndNorthEastSouthPixels,
    'wall_end_north_east_west': wallEndNorthEastWestPixels,
    'wall_end_north_south_west': wallEndNorthSouthWestPixels,
    'wall_end_east_south_west': wallEndEastSouthWestPixels,
    'wall_end_north_east_south_west': wallEndNorthEastSouthWestPixels,
  };

  static PixelMatrix pixelsFor(String spriteId) {
    final pixels = sprites[spriteId];

    if (pixels == null) {
      throw ArgumentError.value(
        spriteId,
        'spriteId',
        'Unknown arcade sprite identifier',
      );
    }

    return pixels;
  }
}
