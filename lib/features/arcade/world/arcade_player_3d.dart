import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ArcadePlayer3D extends StatelessWidget {
  final Offset screenPosition;

  final Flutter3DController controller;

  const ArcadePlayer3D({
    super.key,
    required this.screenPosition,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const width = 80.0;
    const height = 120.0;
    const footOffset = -16.0;

    return Positioned(
      left: screenPosition.dx - width / 2,
      top: screenPosition.dy - height - footOffset,
      width: width,
      height: height,
      child: Flutter3DViewer(
        controller: controller,
        src: 'assets/models/characters/player.glb',
        enableTouch: false,
        activeGestureInterceptor: false,
      ),
    );
  }
}
