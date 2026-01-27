import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'cam_motion.dart';

/// A single “premium” entrance animation: fade + slight slide + slight scale.
/// Use this for cards, sections, headers, etc.
class CamReveal extends StatefulWidget {
  const CamReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = CamMotion.medium,
    this.curve = CamMotion.emphasized,
    this.fromY = 10, // px
    this.fromScale = 0.985,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  /// How many pixels the widget should slide from (down to up).
  final double fromY;

  /// Initial scale (slightly smaller looks premium).
  final double fromScale;

  @override
  State<CamReveal> createState() => _CamRevealState();
}

class _CamRevealState extends State<CamReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (!mounted) return;
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final opacity = _t.value;
        final dy = (1 - _t.value) * widget.fromY;
        final scale = widget.fromScale + (_t.value * (1 - widget.fromScale));

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// A staggered entrance for lists/columns:
/// It reveals children with a small delay between them.
class CamStagger extends StatelessWidget {
  const CamStagger({
    super.key,
    required this.children,
    this.initialDelay = Duration.zero,
    this.step = const Duration(milliseconds: 70),
    this.itemDuration = CamMotion.medium,
    this.curve = CamMotion.emphasized,
    this.padding,
  });

  final List<Widget> children;
  final Duration initialDelay;
  final Duration step;
  final Duration itemDuration;
  final Curve curve;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    for (var i = 0; i < children.length; i++) {
      final d = initialDelay + (step * i);

      items.add(
        CamReveal(
          delay: d,
          duration: itemDuration,
          curve: curve,
          child: children[i],
        ),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );

    return padding == null ? content : Padding(padding: padding!, child: content);
  }
}

/// Smooth “count up” for animated statistics (votes, turnout, etc).
/// Use this inside your stat cards.
class CamCountUp extends StatelessWidget {
  const CamCountUp({
    super.key,
    required this.value,
    this.duration = CamMotion.slow,
    this.curve = CamMotion.emphasized,
    this.format,
  });

  final int value;
  final Duration duration;
  final Curve curve;

  /// Optional formatting function (e.g. add commas).
  final String Function(int v)? format;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) {
        final i = math.min(value, v.round());
        return Text(format?.call(i) ?? '$i');
      },
    );
  }
}