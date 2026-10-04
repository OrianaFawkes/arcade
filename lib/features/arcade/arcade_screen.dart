import 'package:arcade/features/arcade/world/arcade_camera.dart';
import 'package:arcade/features/arcade/world/arcade_world_config.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'world/arcade_world.dart';
import 'world/arcade_world_painter.dart';

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

  @override
  void initState() {
    super.initState();

     world = ArcadeWorld(
      config: const ArcadeWorldConfig(
        width: 30,
        height: 20,
        tileWidth: 72,
        tileHeight: 36,
        spawnPosition: GridPosition(15, 10),
      ),
    );
    camera = ArcadeCamera();

    camera.follow(
      world.playerPosition,
      tileWidth: world.config.tileWidth,
      tileHeight: world.config.tileHeight,
    );

    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {
          camera.update();
        });
      });

      _cameraController.repeat();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _move(int dx, int dy) {
    setState(() {
      world.movePlayer(dx, dy);

      camera.follow(
        world.playerPosition,
        tileWidth: world.config.tileWidth,
        tileHeight: world.config.tileHeight,
      );
    });
  }

  KeyEventResult _handleKeyEvent(
    FocusNode node,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
        _move(0, -1);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.keyS:
        _move(0, 1);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        _move(-1, 0);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        _move(1, 0);
        return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: CustomPaint(
          painter: ArcadeWorldPainter(
            world: world,
            camera: camera,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}