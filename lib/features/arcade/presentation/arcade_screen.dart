import 'dart:async';

import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:arcade/features/arcade/presentation/camera/arcade_camera.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_player.dart';
import 'package:arcade/features/arcade/domain/arcade_station.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_cabinet.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_wall.dart';
import 'package:arcade/features/arcade/domain/arcade_world.dart';
import 'package:arcade/features/arcade/data/arcade_world_loader.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_world_painter.dart';
import 'package:arcade/features/arcade/domain/grid_position.dart';
import 'package:arcade/features/arcade/presentation/rendering/top_down_projection.dart';
import 'package:arcade/features/arcade/domain/path_finder.dart';
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
  late final ArcadeVisualConfig visualConfig;

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

  @override
  void initState() {
    super.initState();

    visualConfig = ArcadeVisualConfig(pixelScale: 2);

    _cameraController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(_updateCamera);
    _cameraController.repeat();

    _camera = ArcadeCamera();

    _worldLoader = ArcadeWorldLoader();

    _pathFinder = PathFinder();

    _loadWorld();
  }

  @override
  void dispose() {
    _cameraController.dispose();

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
      tileWidth: visualConfig.tileWidth,
      tileHeight: visualConfig.tileHeight,
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

  void _handleTap(Offset position, Size size) {
    final currentWorld = _world;

    if (currentWorld == null) return;

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
      _pathMovementTimer?.cancel();
      _pathMovementTimer = null;

      return;
    }

    final next = _path.removeAt(0);

    final dx = next.x - currentWorld.playerPosition.x;
    final dy = next.y - currentWorld.playerPosition.y;

    setState(() {
      if (currentWorld.movePlayer(dx, dy)) {
        _camera.follow(currentWorld.playerPosition, projection: _projection);
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

  void _tryInteract() {
    final currentWorld = _world;

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
    final currentWorld = _world;

    if (currentWorld == null) return null;

    final targetPosition = _positionInFrontOfPlayer();

    for (final station in currentWorld.stations) {
      if (station.position == targetPosition) return station;
    }

    return null;
  }

  @override
  Widget build(_) {
    final currentWorld = _world;

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

            if (!mounted) return;

            setState(() {});
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

                depthObjects.add((
                  depth: groundPosition.dy,
                  widget: ArcadeWall(
                    key: ValueKey('wall-$x-$y'),
                    spriteAsset: 'assets/sprites/wall/arcade-wall.png',
                    groundPosition: groundPosition,
                    visualConfig: visualConfig,
                  ),
                ));
              }
            }

            for (final station in currentWorld.stations) {
              final groundPosition =
                  cameraOffset + _projection.worldToScreen(station.position);

              depthObjects.add((
                depth: groundPosition.dy,
                widget: ArcadeCabinet(
                  key: ValueKey('station-${station.id}'),
                  label: station.label,
                  spriteAsset: 'assets/sprites/cabinet/arcade_cabinet.png',
                  groundPosition: groundPosition,
                  canInteract: _stationInFrontOfPlayer()?.id == station.id,
                  visualConfig: visualConfig,
                ),
              ));
            }

            depthObjects.add((
              depth: playerScreenPosition.dy,
              widget: ArcadePlayer(
                key: ValueKey('arcade-player'),
                direction: currentWorld.playerDirection,
                groundPosition: playerScreenPosition,
                isMoving: _heldKeys.any(_isMovementKey) || _path.isNotEmpty,
                visualConfig: visualConfig,
              ),
            ));

            depthObjects.sort((a, b) => a.depth.compareTo(b.depth));

            return GestureDetector(
              behavior: .opaque,
              onTapDown: (details) => _handleTap(details.localPosition, size),
              child: Stack(
                clipBehavior: .hardEdge,
                children: [
                  CustomPaint(
                    painter: ArcadeWorldPainter(
                      world: currentWorld,
                      camera: _camera,
                      projection: _projection,
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
