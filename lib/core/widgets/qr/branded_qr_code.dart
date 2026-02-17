import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shared QR renderer with embedded CamVote logo.
class BrandedQrCode extends StatelessWidget {
  const BrandedQrCode({
    super.key,
    required this.data,
    this.size = 160,
    this.backgroundColor = Colors.white,
    this.moduleColor = Colors.black,
    this.padding = const EdgeInsets.all(12),
    this.logoAsset = 'assets/icons/app_icon.png',
    this.logoScale = 0.17,
    this.animatedFrame = true,
  });

  final String data;
  final double size;
  final Color backgroundColor;
  final Color moduleColor;
  final EdgeInsets padding;
  final String logoAsset;
  final double logoScale;
  final bool animatedFrame;

  @override
  Widget build(BuildContext context) {
    final payloadLength = data.trim().length;
    final resolvedLogoScale = payloadLength > 220
        ? logoScale.clamp(0.11, 0.15).toDouble()
        : payloadLength > 120
        ? logoScale.clamp(0.12, 0.17).toDouble()
        : logoScale.clamp(0.12, 0.2).toDouble();
    final qrSize = (size - 16).clamp(48, size).toDouble();
    final embeddedSize = Size.square(
      (qrSize * resolvedLogoScale).clamp(14, qrSize * 0.3),
    );
    return Center(
      child: CamVoteAnimatedQrFrame(
        size: size,
        animated: animatedFrame,
        child: QrImageView(
          data: data,
          size: qrSize,
          padding: padding,
          backgroundColor: backgroundColor,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
          gapless: true,
          eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: moduleColor),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: moduleColor,
          ),
          embeddedImage: AssetImage(logoAsset),
          embeddedImageStyle: QrEmbeddedImageStyle(size: embeddedSize),
        ),
      ),
    );
  }
}

class CamVoteAnimatedQrFrame extends StatefulWidget {
  const CamVoteAnimatedQrFrame({
    super.key,
    required this.size,
    required this.child,
    this.animated = true,
  });

  final double size;
  final Widget child;
  final bool animated;

  @override
  State<CamVoteAnimatedQrFrame> createState() => _CamVoteAnimatedQrFrameState();
}

class _CamVoteAnimatedQrFrameState extends State<CamVoteAnimatedQrFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    final animate =
        widget.animated && disableAnimations != true && TickerMode.of(context);
    final content = RepaintBoundary(
      child: Container(
        width: widget.size,
        height: widget.size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: widget.child,
      ),
    );

    if (!animate) {
      return _QrFrameShell(intensity: 0.45, size: widget.size, child: content);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = Curves.easeInOut.transform(_controller.value);
        return _QrFrameShell(
          intensity: pulse,
          size: widget.size,
          child: content,
        );
      },
    );
  }
}

class _QrFrameShell extends StatelessWidget {
  const _QrFrameShell({
    required this.intensity,
    required this.size,
    required this.child,
  });

  final double intensity;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glowAlpha = 30 + (intensity * 55).round();
    final borderAlpha = 95 + (intensity * 80).round();
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary.withAlpha(22), cs.tertiary.withAlpha(18)],
          ),
          border: Border.all(
            color: cs.primary.withAlpha(borderAlpha.clamp(0, 255)),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withAlpha(glowAlpha.clamp(0, 255)),
              blurRadius: 14 + (intensity * 8),
              spreadRadius: 0.6 + (intensity * 0.6),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
