import 'package:arcade/features/arcade/domain/arcade_station.dart';
import 'package:arcade/shared/presentation/widgets/dialog_container.dart';
import 'package:arcade/shared/presentation/widgets/pixel_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StationDialog extends StatelessWidget {
  final ArcadeStation station;

  const StationDialog({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DialogContainer(
      width: 280.0,
      child: Column(
        mainAxisSize: .min,
        spacing: 16.0,
        children: [
          Text(station.label, style: textTheme.titleLarge),
          // TODO: improve band-aid solution
          if (station.id.contains('out_of_order')) ...[
            Text(
              'This feature is currently out of order. Please try again later.',
              style: textTheme.bodyMedium,
            ),
            PixelButton(
              height: 36.0,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Nevermind',
                style: textTheme.bodyLarge?.copyWith(color: Color(0xFF383138)),
              ),
            ),
          ] else ...[
            Text('Ready to play this game?', style: textTheme.bodyMedium),
            Row(
              spacing: 8.0,
              children: [
                Expanded(
                  child: PixelButton(
                    height: 36.0,
                    fillColor: Color(0xFF36343D),
                    borderColor: Color(0xFFF2D3F2),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Not now', style: textTheme.bodyLarge),
                  ),
                ),
                Expanded(
                  child: PixelButton(
                    height: 36.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(station.routeName);
                    },
                    child: Text(
                      'Play',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Color(0xFF383138),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
