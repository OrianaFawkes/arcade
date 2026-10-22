import 'package:arcade/features/arcade/domain/arcade_station.dart';
import 'package:arcade/shared/presentation/widgets/dialog_container.dart';
import 'package:arcade/shared/presentation/widgets/pixel_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StationDialog extends StatefulWidget {
  final ArcadeStation station;

  const StationDialog({super.key, required this.station});

  @override
  State<StationDialog> createState() => _StationDialogState();
}

class _StationDialogState extends State<StationDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      width: 280.0,
      child: Column(
        mainAxisSize: .min,
        spacing: 16.0,
        children: [
          Text(
            widget.station.label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Ready to play this game?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            spacing: 8.0,
            children: [
              Expanded(
                child: PixelButton(
                  height: 36.0,
                  fillColor: Color(0xFF383138),
                  borderColor: Color(0xFFF2D3F2),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Not now',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              Expanded(
                child: PixelButton(
                  height: 36.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(widget.station.routeName);
                  },
                  child: Text(
                    'Play',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Color(0xFF383138)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
