import 'package:arcade/features/arcade/presentation/generated/arcade_tile_pixels.dart';

typedef PixelMatrix = List<List<int>>;

class ArcadeSpriteRegistry {
  ArcadeSpriteRegistry._();

  static const Map<String, PixelMatrix> sprites = {
    'floor': floorPixels,
    'floor_end_north': floorEndNorthPixels,
    'floor_end_east': floorEndEastPixels,
    'floor_end_south': floorEndSouthPixels,
    'floor_end_west': floorEndWestPixels,
    'floor_end_north_east': floorEndNorthEastPixels,
    'floor_end_north_south': floorEndNorthSouthPixels,
    'floor_end_north_west': floorEndNorthWestPixels,
    'floor_end_east_south': floorEndEastSouthPixels,
    'floor_end_east_west': floorEndEastWestPixels,
    'floor_end_south_west': floorEndSouthWestPixels,
    'floor_end_north_east_south': floorEndNorthEastSouthPixels,
    'floor_end_north_east_west': floorEndNorthEastWestPixels,
    'floor_end_north_south_west': floorEndNorthSouthWestPixels,
    'floor_end_east_south_west': floorEndEastSouthWestPixels,
    'floor_end_north_east_south_west': floorEndNorthEastSouthWestPixels,
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
