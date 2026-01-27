import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final resolvedPadding = _adaptivePadding(padding, width);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: resolvedPadding,
              child: child,
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _adaptivePadding(EdgeInsets base, double width) {
    if (width <= 340) {
      return EdgeInsets.fromLTRB(
        math.min(base.left, 10),
        base.top,
        math.min(base.right, 10),
        base.bottom,
      );
    }
    if (width <= 380) {
      return EdgeInsets.fromLTRB(
        math.min(base.left, 12),
        base.top,
        math.min(base.right, 12),
        base.bottom,
      );
    }
    return base;
  }
}
