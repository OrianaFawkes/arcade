import 'package:flutter/material.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget widget,
  bool barrierDismissible = true,
  bool isMobile = true,
  String barrierLabel = 'Dialog',
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: Color(0xFF2D1B1B).withValues(alpha: 0.2),
    transitionDuration: Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => widget,
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: isMobile ? Offset(0, 0.1) : Offset(1, 0),
            end: .zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
