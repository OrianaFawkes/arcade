import 'dart:async';

import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:arcade/features/arcade/presentation/camera/arcade_camera.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_player.dart';
import 'package:arcade/features/arcade/domain/arcade_station.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_cabinet.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_sprite_cache.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_tile_resolver.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_wall.dart';
import 'package:arcade/features/arcade/domain/arcade_world.dart';
import 'package:arcade/features/arcade/data/arcade_world_loader.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_world_painter.dart';
import 'package:arcade/features/arcade/domain/grid_position.dart';
import 'package:arcade/features/arcade/presentation/rendering/top_down_projection.dart';
import 'package:arcade/features/arcade/domain/path_finder.dart';
import 'package:arcade/features/arcade/presentation/station_dialog.dart';
import 'package:arcade/shared/presentation/dialogs/app_dialog.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArcadeWorldCard extends StatefulWidget {
  const ArcadeWorldCard({super.key});

  @override
  State<ArcadeWorldCard> createState() => _ArcadeWorldCardState();
}

class _ArcadeWorldCardState extends State<ArcadeWorldCard>
    with SingleTickerProviderStateMixin {
  late final ArcadeVisualConfig _visualConfig;

  late final AnimationController _cameraController;

  late final ArcadeCamera _camera;

  late final ArcadeWorldLoader _worldLoader;

  late final PathFinder _pathFinder;

  late TopDownProjection _projection;

  final Set<LogicalKeyboardKey> _heldKeys = {};

  List<GridPosition> _path = [];

  ArcadeWorld? _world;

  Timer? _movementRepeatStartTimer;
  Timer? _movementRepeatTimer;
  Timer? _pathMovementTimer;

  String? _pendingStationId;

  @override
  void initState() {
    super.initState();

    _visualConfig = ArcadeVisualConfig(pixelScale: 2);

    _cameraController =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..addListener(_updateCamera)
          ..repeat();

    _camera = ArcadeCamera();

    _worldLoader = ArcadeWorldLoader();

    _pathFinder = PathFinder();

    _loadWorld();
  }

  @override
  void dispose() {
    _cameraController
      ..removeListener(_updateCamera)
      ..dispose();

    _movementRepeatStartTimer?.cancel();
    _movementRepeatTimer?.cancel();
    _pathMovementTimer?.cancel();

    super.dispose();
  }

  void _updateCamera() {
    if (!mounted || _world == null) return;

    _camera.update();

    setState(() {});
  }

  Future<void> _loadWorld() async {
    final layout = await _worldLoader.load('assets/worlds/arcade_world.json');

    final loadedWorld = ArcadeWorld(layout: layout);

    final loadedProjection = TopDownProjection(
      tileWidth: _visualConfig.tileWidth,
      tileHeight: _visualConfig.tileHeight,
    );

    _camera.snapTo(loadedWorld.playerPosition, projection: loadedProjection);

    if (!mounted) return;

    setState(() {
      _world = loadedWorld;

      _projection = loadedProjection;
    });
  }

  GridPosition _screenToGrid(Offset screenPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cameraOffset = center - _camera.position;
    final worldScreenPosition = screenPosition - cameraOffset;

    return _projection.screenToGrid(worldScreenPosition);
  }

  void _approachStation(ArcadeStation station) {
    final currentWorld = _world;
    if (currentWorld == null) return;

    _stopPathMovement();

    _path.clear();

    _pendingStationId = null;

    final playerPosition = currentWorld.playerPosition;

    final adjacentPositions = <GridPosition>[
      station.position.copyWith(y: station.position.y - 1),
      station.position.copyWith(y: station.position.y + 1),
      station.position.copyWith(x: station.position.x - 1),
      station.position.copyWith(x: station.position.x + 1),
    ];

    List<GridPosition>? bestPath;

    for (final goal in adjacentPositions) {
      if (!currentWorld.grid.isWalkable(goal)) continue;

      final candidatePath = _pathFinder.findPath(
        grid: currentWorld.grid,
        start: playerPosition,
        goal: goal,
      );

      if (candidatePath == null) continue;

      if (bestPath == null || candidatePath.length < bestPath.length) {
        bestPath = candidatePath;
      }
    }

    if (bestPath == null) return;

    // Already standing on a valid adjacent tile
    if (bestPath.length == 1) {
      _faceAndShowStation(station);
      return;
    }

    _pendingStationId = station.id;

    _path = bestPath.skip(1).toList();

    _startPathMovement();
  }

  Future<void> _faceAndShowStation(ArcadeStation station) async {
    final currentWorld = _world;
    if (currentWorld == null) return;
    if (!currentWorld.facePosition(station.position)) return;

    setState(() {});

    await showAppDialog(
      context: context,
      barrierLabel: 'Station',
      widget: StationDialog(station: station),
    );
  }

  void _completePendingStationInteraction() {
    final stationId = _pendingStationId;
    final currentWorld = _world;

    if (stationId == null || currentWorld == null) return;

    ArcadeStation? station;

    for (final candidate in currentWorld.stations) {
      if (candidate.id == stationId) {
        station = candidate;
        break;
      }
    }

    _pendingStationId = null;

    if (station == null) return;

    // Only interact if adjacent
    final dx = (station.position.x - currentWorld.playerPosition.x).abs();
    final dy = (station.position.y - currentWorld.playerPosition.y).abs();

    if (dx + dy != 1) return;

    _faceAndShowStation(station);
  }

  void _handleTap(Offset position, Size size) {
    final currentWorld = _world;
    if (currentWorld == null) return;

    final station = _stationAtScreenPosition(position, size);

    if (station != null) {
      _approachStation(station);

      return;
    }

    // A new floor destination cancels any pending interaction
    _pendingStationId = null;

    final target = _screenToGrid(position, size);

    if (!currentWorld.grid.isWalkable(target)) return;

    final path = _pathFinder.findPath(
      grid: currentWorld.grid,
      start: currentWorld.playerPosition,
      goal: target,
    );

    if (path == null || path.length < 2) return;

    _path = path.skip(1).toList();

    _startPathMovement();
  }

  void _updatePathMovement() {
    final currentWorld = _world;

    if (currentWorld == null || _path.isEmpty) {
      _stopPathMovement();

      if (_pendingStationId != null) _completePendingStationInteraction();

      return;
    }

    final next = _path.removeAt(0);
    final dx = next.x - currentWorld.playerPosition.x;
    final dy = next.y - currentWorld.playerPosition.y;

    setState(() {
      if (currentWorld.movePlayer(dx, dy)) {
        _camera.follow(currentWorld.playerPosition, projection: _projection);
      } else {
        // Stop if the world changed or the next move is blocked
        _path.clear();

        _pendingStationId = null;
      }
    });

    if (_path.isEmpty) {
      _stopPathMovement();

      if (_pendingStationId != null) _completePendingStationInteraction();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;

    if (event.logicalKey == .keyE ||
        event.logicalKey == .enter ||
        event.logicalKey == .numpadEnter) {
      _tryInteract();

      return .handled;
    }

    if (!_isMovementKey(key)) return .ignored;

    if (event is KeyDownEvent) {
      // Ignore browser/OS key-repeat events.
      final isNewKey = _heldKeys.add(key);
      if (!isNewKey) return .handled;

      // Keyboard movement takes priority over
      // an existing click-to-move path
      _pendingStationId = null;

      _path.clear();

      _stopPathMovement();

      _moveFromHeldKeys();

      _startMovementRepeat();

      return .handled;
    }

    if (event is KeyUpEvent) {
      final wasHeld = _heldKeys.remove(key);

      if (_heldKeys.isEmpty) _stopMovementRepeat();

      if (wasHeld && mounted) setState(() {});

      return .handled;
    }

    return .ignored;
  }

  bool _isMovementKey(LogicalKeyboardKey key) {
    return key == .arrowUp ||
        key == .arrowDown ||
        key == .arrowLeft ||
        key == .arrowRight ||
        key == .keyW ||
        key == .keyA ||
        key == .keyS ||
        key == .keyD;
  }

  void _startMovementRepeat() {
    _movementRepeatStartTimer?.cancel();
    _movementRepeatTimer?.cancel();

    _movementRepeatStartTimer = Timer(Duration(milliseconds: 250), () {
      if (_heldKeys.isEmpty) return;

      _moveFromHeldKeys();

      _movementRepeatTimer = Timer.periodic(Duration(milliseconds: 120), (_) {
        if (_heldKeys.isEmpty) {
          _stopMovementRepeat();
          return;
        }

        _moveFromHeldKeys();
      });
    });
  }

  void _startPathMovement() {
    _stopPathMovement();

    _pathMovementTimer = Timer.periodic(Duration(milliseconds: 150), (_) {
      _updatePathMovement();
    });
  }

  void _stopMovementRepeat() {
    _movementRepeatStartTimer?.cancel();
    _movementRepeatStartTimer = null;

    _movementRepeatTimer?.cancel();
    _movementRepeatTimer = null;
  }

  void _stopPathMovement() {
    _pathMovementTimer?.cancel();
    _pathMovementTimer = null;
  }

  void _moveFromHeldKeys() {
    final currentWorld = _world;
    if (currentWorld == null) return;

    var dx = 0;
    var dy = 0;

    if (_heldKeys.contains(LogicalKeyboardKey.arrowUp) ||
        _heldKeys.contains(LogicalKeyboardKey.keyW)) {
      dy = -1;
    } else if (_heldKeys.contains(LogicalKeyboardKey.arrowDown) ||
        _heldKeys.contains(LogicalKeyboardKey.keyS)) {
      dy = 1;
    } else if (_heldKeys.contains(LogicalKeyboardKey.arrowLeft) ||
        _heldKeys.contains(LogicalKeyboardKey.keyA)) {
      dx = -1;
    } else if (_heldKeys.contains(LogicalKeyboardKey.arrowRight) ||
        _heldKeys.contains(LogicalKeyboardKey.keyD)) {
      dx = 1;
    }

    if (dx == 0 && dy == 0) return;

    setState(() {
      if (currentWorld.movePlayer(dx, dy)) {
        _camera.follow(currentWorld.playerPosition, projection: _projection);
      }
    });
  }

  GridPosition _positionInFrontOfPlayer() {
    final position = _world!.playerPosition;

    return switch (_world!.playerDirection) {
      .north => position.copyWith(y: position.y - 1),
      .east => position.copyWith(x: position.x + 1),
      .south => position.copyWith(y: position.y + 1),
      .west => position.copyWith(x: position.x - 1),
    };
  }

  Future<void> _tryInteract() async {
    final station = _stationInFrontOfPlayer();
    if (station == null) return;

    await showAppDialog(
      context: context,
      barrierLabel: 'Station',
      widget: StationDialog(station: station),
    );
  }

  ArcadeStation? _stationInFrontOfPlayer() {
    final currentWorld = _world;
    if (currentWorld == null) return null;

    final targetPosition = _positionInFrontOfPlayer();

    for (final station in currentWorld.stations) {
      if (station.position == targetPosition) return station;
    }

    return null;
  }

  ArcadeStation? _stationAtScreenPosition(Offset tapPosition, Size size) {
    final currentWorld = _world;
    if (currentWorld == null) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final cameraOffset = center - _camera.position;

    for (final station in currentWorld.stations) {
      final groundPosition =
          cameraOffset + _projection.worldToScreen(station.position);

      final left = groundPosition.dx - _visualConfig.tileWidth / 2;
      final top =
          groundPosition.dy -
          _visualConfig.stationHeight +
          _visualConfig.tileHeight / 2;

      final bounds = Rect.fromLTWH(
        left,
        top,
        _visualConfig.tileWidth,
        _visualConfig.stationHeight,
      );

      if (bounds.contains(tapPosition)) return station;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentWorld = _world;

    if (currentWorld == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        PixelCard(
          borderColor: Color(0xFFF2D3F2),
          fillColor: Color(0xFF36343D),
          padding: .all(2.0),
          radius: 4,
          child: Focus(
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: FutureBuilder<void>(
              future: ArcadeSpriteCache.instance.initialize(),
              builder: (_, snapshot) {
                if (snapshot.connectionState != .done) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to initialize arcade sprites.'),
                  );
                }

                return LayoutBuilder(
                  builder: (_, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    final center = Offset(size.width / 2, size.height / 2);
                    final cameraOffset = center - _camera.position;

                    final playerScreenPosition =
                        cameraOffset +
                        _projection.worldToScreen(currentWorld.playerPosition);

                    final depthObjects = <({double depth, Widget widget})>[];

                    for (var y = 0; y < currentWorld.grid.height; y++) {
                      for (var x = 0; x < currentWorld.grid.width; x++) {
                        final position = GridPosition(x, y);
                        final cell = currentWorld.grid.cellAt(position);

                        if (cell.terrain != .wall) continue;

                        final tileCenter =
                            cameraOffset + _projection.worldToScreen(position);

                        final groundPosition =
                            tileCenter + Offset(0, _projection.tileHeight / 2);

                        final spriteId = ArcadeTileResolver().resolve(
                          currentWorld,
                          position,
                        );

                        depthObjects.add((
                          depth: groundPosition.dy,
                          widget: ArcadeWall(
                            key: ValueKey('wall_${x}_$y'),
                            spriteId: spriteId,
                            groundPosition: groundPosition,
                            visualConfig: _visualConfig,
                          ),
                        ));
                      }
                    }

                    for (final station in currentWorld.stations) {
                      final groundPosition =
                          cameraOffset +
                          _projection.worldToScreen(station.position);

                      depthObjects.add((
                        depth: groundPosition.dy,
                        widget: ArcadeCabinet(
                          key: ValueKey('station_${station.id}'),
                          label: station.label,
                          spriteAsset:
                              'assets/sprites/cabinet/${station.id}.png',
                          groundPosition: groundPosition,
                          canInteract:
                              _stationInFrontOfPlayer()?.id == station.id,
                          visualConfig: _visualConfig,
                        ),
                      ));
                    }

                    depthObjects.add((
                      depth: playerScreenPosition.dy,
                      widget: ArcadePlayer(
                        key: ValueKey('arcade_player'),
                        direction: currentWorld.playerDirection,
                        groundPosition: playerScreenPosition,
                        isMoving:
                            _heldKeys.any(_isMovementKey) || _path.isNotEmpty,
                        visualConfig: _visualConfig,
                      ),
                    ));

                    depthObjects.sort((a, b) => a.depth.compareTo(b.depth));

                    return GestureDetector(
                      behavior: .opaque,
                      onTapDown: (details) {
                        _handleTap(details.localPosition, size);
                      },
                      child: Stack(
                        clipBehavior: .hardEdge,
                        children: [
                          CustomPaint(
                            painter: ArcadeWorldPainter(
                              world: currentWorld,
                              camera: _camera,
                              projection: _projection,
                              visualConfig: _visualConfig,
                            ),
                            size: size,
                          ),
                          ...depthObjects.map((item) => item.widget),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        IgnorePointer(
          child: PixelCard(
            borderColor: Color(0xFFF2D3F2),
            fillColor: Colors.transparent,
            padding: .zero,
            radius: 4,
            hasShadow: false,
            child: SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
