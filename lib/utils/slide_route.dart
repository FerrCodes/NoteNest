import 'package:flutter/material.dart';

/// Route dengan animasi slide dari kanan ke kiri (gaya iOS).
///
/// Penggunaan:
/// ```dart
/// Navigator.push(context, SlideRoute(page: const MyScreen()));
/// ```
class SlideRoute extends PageRouteBuilder {
  final Widget page;

  SlideRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 260),
      );
}
