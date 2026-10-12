import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSystemBarScope extends StatelessWidget {
  final Widget child;
  final Color color;

  const AppSystemBarScope({
    super.key,
    required this.child,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final barHeight = mq.viewPadding.bottom;

    final iconBrightness =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    final overlayStyle = SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      systemNavigationBarDividerColor: color,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarContrastEnforced: false,
    );

    final adjusted = mq.copyWith(
      padding: mq.padding.copyWith(bottom: 0),
      viewPadding: mq.viewPadding.copyWith(bottom: 0),
      viewInsets: mq.viewInsets.copyWith(
        bottom: math.max(0.0, mq.viewInsets.bottom - barHeight),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: ColoredBox(
        color: color,
        child: Column(
          children: [
            Expanded(
              child: MediaQuery(data: adjusted, child: child),
            ),
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: SizedBox(height: barHeight, width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
