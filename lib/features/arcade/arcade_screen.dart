import 'dart:async';

import 'package:arcade/features/arcade/world/arcade_camera.dart';
import 'package:arcade/features/arcade/world/arcade_world.dart';
import 'package:arcade/features/arcade/world/arcade_world_config.dart';
import 'package:arcade/features/arcade/world/arcade_world_painter.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/isometric_projection.dart';
import 'package:arcade/features/arcade/world/path_finder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cameraController;

  late final ArcadeWorld world;

  late final ArcadeCamera camera;

  late final IsometricProjection projection;

  final Set<LogicalKeyboardKey> _heldKeys = {};

  final pathFinder = PathFinder();

  List<GridPosition> _path = [];

  Timer? _movementTimer;

  @override
  void initState() {
    super.initState();

    world = ArcadeWorld(
      config: ArcadeWorldConfig(
        width: 30,
        height: 20,
        tileWidth: 72,
        tileHeight: 36,
        spawnPosition: GridPosition(15, 10),
      ),
    );

    projection = IsometricProjection(
      tileWidth: world.config.tileWidth,
      tileHeight: world.config.tileHeight,
    );

    camera = ArcadeCamera();
    camera.follow(world.playerPosition, projection: projection);

    _cameraController =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..addListener(() {
            setState(() => camera.update());
          });
    _cameraController.repeat();

    _movementTimer = Timer.periodic(
      Duration(milliseconds: 120),
      (_) => _updateMovement(),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();

    _movementTimer?.cancel();

    super.dispose();
  }

  GridPosition _screenToGrid(Offset screenPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cameraOffset = center - camera.position;
    final worldScreenPosition = screenPosition - cameraOffset;

    return projection.screenToGrid(worldScreenPosition);
  }

  void _handleTap(Offset position, Size size) {
    final target = _screenToGrid(position, size);

    if (!world.grid.isWalkable(target)) return;

    final path = pathFinder.findPath(
      grid: world.grid,
      start: world.playerPosition,
      goal: target,
    );

    if (path == null) return;

    setState(() => _path = path.skip(1).toList());
  }

  void _updateMovement() {
    if (_heldKeys.isNotEmpty) {
      _moveFromHeldKeys();

      return;
    }

    if (_path.isEmpty) return;

    final next = _path.removeAt(0);

    final dx = next.x - world.playerPosition.x;
    final dy = next.y - world.playerPosition.y;

    if (world.movePlayer(dx, dy)) {
      setState(() {
        camera.follow(world.playerPosition, projection: projection);
      });
    } else {
      setState(() => _path.clear());
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      if (_isMovementKey(key)) {
        _heldKeys.add(key);

        // Cancel an existing click-to-move path.
        _path.clear();

        // Move immediately rather than waiting for the timer.
        _moveFromHeldKeys();

        return .handled;
      }
    }

    if (event is KeyUpEvent) {
      _heldKeys.remove(event.logicalKey);

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

  void _moveFromHeldKeys() {
    var dx = 0;
    var dy = 0;

    if (_heldKeys.contains(LogicalKeyboardKey.arrowUp) ||
        _heldKeys.contains(LogicalKeyboardKey.keyW)) {
      dy = -1;
    }

    if (_heldKeys.contains(LogicalKeyboardKey.arrowDown) ||
        _heldKeys.contains(LogicalKeyboardKey.keyS)) {
      dy = 1;
    }

    if (_heldKeys.contains(LogicalKeyboardKey.arrowLeft) ||
        _heldKeys.contains(LogicalKeyboardKey.keyA)) {
      dx = -1;
    }

    if (_heldKeys.contains(LogicalKeyboardKey.arrowRight) ||
        _heldKeys.contains(LogicalKeyboardKey.keyD)) {
      dx = 1;
    }

    if (dx == 0 && dy == 0) return;

    if (world.movePlayer(dx, dy)) {
      setState(() {
        camera.follow(world.playerPosition, projection: projection);
      });
    }

    if (dx != 0) dy = 0;
  }

  @override
  Widget build(_) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            return GestureDetector(
              behavior: .opaque,
              onTapDown: (details) {
                _handleTap(details.localPosition, size);
              },
              child: CustomPaint(
                painter: ArcadeWorldPainter(
                  world: world,
                  camera: camera,
                  projection: projection,
                ),
                size: size,
              ),
            );
          },
        ),
      ),
    );
  }
}
