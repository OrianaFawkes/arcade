import 'dart:async';

import 'package:arcade/features/arcade/world/arcade_camera.dart';
import 'package:arcade/features/arcade/world/arcade_player_painter.dart';
import 'package:arcade/features/arcade/world/arcade_station.dart';
import 'package:arcade/features/arcade/world/arcade_station_placeholder.dart';
import 'package:arcade/features/arcade/world/arcade_wall_placeholder.dart';
import 'package:arcade/features/arcade/world/arcade_world.dart';
import 'package:arcade/features/arcade/world/arcade_world_loader.dart';
import 'package:arcade/features/arcade/world/arcade_world_painter.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/player_direction.dart';
import 'package:arcade/features/arcade/world/top_down_projection.dart';
import 'package:arcade/features/arcade/world/path_finder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cameraController;

  late final ArcadeWorldLoader worldLoader;

  late final ArcadeCamera _camera;

  late TopDownProjection projection;

  final Set<LogicalKeyboardKey> _heldKeys = {};

  final pathFinder = PathFinder();

  List<GridPosition> _path = [];

  Timer? _movementRepeatStartTimer;
  Timer? _movementRepeatTimer;
  Timer? _pathMovementTimer;

  ArcadeWorld? world;

  @override
  void initState() {
    super.initState();

    worldLoader = ArcadeWorldLoader();

    _camera = ArcadeCamera();

    _loadWorld();

    _cameraController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(_updateCamera);
    _cameraController.repeat();
  }

  @override
  void dispose() {
    _movementRepeatStartTimer?.cancel();
    _movementRepeatTimer?.cancel();
    _pathMovementTimer?.cancel();

    _cameraController.dispose();

    super.dispose();
  }

  void _updateCamera() {
    if (!mounted || world == null) return;

    _camera.update();

    setState(() {});
  }

  Future<void> _loadWorld() async {
    final layout = await worldLoader.load('assets/worlds/arcade_world.json');

    final loadedWorld = ArcadeWorld(layout: layout);

    final loadedProjection = TopDownProjection(tileWidth: 40, tileHeight: 20);

    _camera.snapTo(loadedWorld.playerPosition, projection: loadedProjection);

    if (!mounted) return;

    setState(() {
      world = loadedWorld;
      projection = loadedProjection;
    });
  }

  GridPosition _screenToGrid(Offset screenPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cameraOffset = center - _camera.position;
    final worldScreenPosition = screenPosition - cameraOffset;

    return projection.screenToGrid(worldScreenPosition);
  }

  void _handleTap(Offset position, Size size) {
    final currentWorld = world;

    if (currentWorld == null) return;

    final target = _screenToGrid(position, size);

    if (!currentWorld.grid.isWalkable(target)) return;

    final path = pathFinder.findPath(
      grid: currentWorld.grid,
      start: currentWorld.playerPosition,
      goal: target,
    );

    if (path == null || path.length < 2) return;

    _path = path.skip(1).toList();

    _startPathMovement();
  }

  void _updatePathMovement() {
    final currentWorld = world;

    if (currentWorld == null || _path.isEmpty) {
      _pathMovementTimer?.cancel();
      _pathMovementTimer = null;

      return;
    }

    final next = _path.removeAt(0);

    final dx = next.x - currentWorld.playerPosition.x;
    final dy = next.y - currentWorld.playerPosition.y;

    setState(() {
      if (currentWorld.movePlayer(dx, dy)) {
        // follow
        _camera.snapTo(currentWorld.playerPosition, projection: projection);

        _camera.update();
      } else {
        _path.clear();
      }
    });

    if (_path.isEmpty) {
      _pathMovementTimer?.cancel();
      _pathMovementTimer = null;
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
      //
      // The Set tells us whether this is the first key-down
      // for this physical key.
      final isNewKey = _heldKeys.add(key);

      if (!isNewKey) return .handled;

      // Keyboard movement takes priority over an existing
      // click-to-move path.
      _path.clear();

      _stopPathMovement();

      // One physical key press = exactly one movement.
      _moveFromHeldKeys();

      // Start controlled key-repeat after a short delay.
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
    final currentWorld = world;

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

    // setState(() {
    //   if (currentWorld.movePlayer(dx, dy)) {
    //     // follow
    //     _camera.snapTo(currentWorld.playerPosition, projection: projection);

    //     _camera.update();
    //   }
    // });
    final target = currentWorld.playerPosition.copyWith(
      x: currentWorld.playerPosition.x + dx,
      y: currentWorld.playerPosition.y + dy,
    );

    setState(() {
      if (currentWorld.movePlayer(dx, dy)) {
        _camera.snapTo(currentWorld.playerPosition, projection: projection);
        _camera.update();
      }
    });
  }

  GridPosition _positionInFrontOfPlayer() {
    final position = world!.playerPosition;

    return switch (world!.playerDirection) {
      PlayerDirection.north => position.copyWith(y: position.y - 1),
      PlayerDirection.east => position.copyWith(x: position.x + 1),
      PlayerDirection.south => position.copyWith(y: position.y + 1),
      PlayerDirection.west => position.copyWith(x: position.x - 1),
    };
  }

  void _tryInteract() {
    final currentWorld = world;
    if (currentWorld == null) return;

    final targetPosition = _positionInFrontOfPlayer();

    ArcadeStation? targetStation;

    for (final station in currentWorld.stations) {
      if (station.position == targetPosition) {
        targetStation = station;
        break;
      }
    }

    if (targetStation == null) return;

    final station = _stationInFrontOfPlayer();

    if (station == null) return;

    context.go(targetStation.routeName);
  }

  ArcadeStation? _stationInFrontOfPlayer() {
    final currentWorld = world;
    if (currentWorld == null) return null;

    final targetPosition = _positionInFrontOfPlayer();

    for (final station in currentWorld.stations) {
      if (station.position == targetPosition) {
        return station;
      }
    }

    return null;
  }

  @override
  Widget build(_) {
    final currentWorld = world;

    if (currentWorld == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Focus(
        autofocus: true,
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _heldKeys.clear();
            _stopMovementRepeat();

            if (mounted) {
              setState(() {});
            }
          }
        },
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            final center = Offset(size.width / 2, size.height / 2);

            final cameraOffset = center - _camera.position;

            final playerScreenPosition =
                cameraOffset +
                projection.worldToScreen(currentWorld.playerPosition);

            // return GestureDetector(
            //   behavior: .opaque,
            //   onTapDown: (details) {
            //     _handleTap(details.localPosition, size);
            //   },
            //   child: Stack(
            //     children: [
            //       CustomPaint(
            //         painter: ArcadeWorldPainter(
            //           world: currentWorld,
            //           camera: _camera,
            //           projection: projection,
            //         ),
            //         size: size,
            //       ),
            //       ArcadePlayerPainter(
            //         groundPosition: playerScreenPosition,
            //         direction: currentWorld.playerDirection,
            //         isMoving: _heldKeys.isNotEmpty || _path.isNotEmpty,
            //       ),
            //     ],
            //   ),
            // );

            final depthObjects = <({double depth, Widget widget})>[];

            for (var y = 0; y < currentWorld.grid.height; y++) {
              for (var x = 0; x < currentWorld.grid.width; x++) {
                final position = GridPosition(x, y);
                final cell = currentWorld.grid.cellAt(position);

                if (cell.terrain != .wall) continue;

                final tileCenter =
                    cameraOffset + projection.worldToScreen(position);

                final groundPosition =
                    tileCenter + Offset(0, projection.tileHeight / 2);

                depthObjects.add((
                  depth: groundPosition.dy,
                  widget: ArcadeWallPlaceholder(
                    key: ValueKey('wall-$x-$y'),
                    groundPosition: groundPosition,
                    tileWidth: projection.tileWidth,
                    visualHeight: 20,
                  ),
                ));
              }
            }

            for (final station in currentWorld.stations) {
              final groundPosition =
                  cameraOffset + projection.worldToScreen(station.position);

              depthObjects.add((
                depth: groundPosition.dy,
                widget: ArcadeStationPlaceholder(
                  key: ValueKey('station-${station.id}'),
                  groundPosition: groundPosition,
                  tileWidth: projection.tileWidth,
                  visualHeight: 50,
                  label: station.label,
                  canInteract: _stationInFrontOfPlayer()?.id == station.id,
                ),
              ));
            }

            depthObjects.add((
              depth: playerScreenPosition.dy,
              widget: ArcadePlayerPainter(
                key: const ValueKey('arcade-player'),
                groundPosition: playerScreenPosition,
                direction: currentWorld.playerDirection,
                isMoving: _heldKeys.any(_isMovementKey) || _path.isNotEmpty,
              ),
            ));

            depthObjects.sort((a, b) => a.depth.compareTo(b.depth));

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                _handleTap(details.localPosition, size);
              },
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  CustomPaint(
                    painter: ArcadeWorldPainter(
                      world: currentWorld,
                      camera: _camera,
                      projection: projection,
                    ),
                    size: size,
                  ),
                  ...depthObjects.map((item) => item.widget),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
