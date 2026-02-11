import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../core/branding/brand_palette.dart';
import '../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../core/widgets/navigation/app_back_button.dart';

class LivenessChallengeScreen extends StatefulWidget {
  const LivenessChallengeScreen({super.key});

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<bool> run(BuildContext context) async {
    if (!isSupportedPlatform) return true;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LivenessChallengeScreen()),
    );
    return result ?? false;
  }

  @override
  State<LivenessChallengeScreen> createState() =>
      _LivenessChallengeScreenState();
}

class _LivenessChallengeScreenState extends State<LivenessChallengeScreen> {
  CameraController? _camera;
  FaceDetector? _detector;
  bool _ready = false;
  bool _processing = false;
  bool _faceVisible = false;
  bool _faceCentered = false;
  String? _error;
  bool _permissionDenied = false;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);

  final List<_LivenessTask> _tasks = [];
  int _taskIndex = 0;
  bool _blinkClosed = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      setState(() {
        _error = t.livenessCameraPermissionRequired;
        _permissionDenied = true;
      });
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      setState(() => _error = t.livenessNoCameraAvailable);
      return;
    }

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _camera = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.12,
      ),
    );

    await _camera!.initialize();
    await _camera!.startImageStream(_processCameraImage);

    if (mounted) {
      final t = AppLocalizations.of(context);
      setState(() {
        _ready = true;
        _tasks
          ..clear()
          ..addAll(_LivenessTask.defaultSequence(t));
      });
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    _detector?.close();
    super.dispose();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_processing || _done) return;
    final now = DateTime.now();
    if (now.difference(_lastFrame).inMilliseconds < 180) return;

    _processing = true;
    _lastFrame = now;

    try {
      final input = _inputImageFromCameraImage(image);
      final faces = await _detector!.processImage(input);
      if (faces.isEmpty) {
        if (_faceVisible || _faceCentered) {
          setState(() {
            _faceVisible = false;
            _faceCentered = false;
          });
        }
        return;
      }
      if (!_faceVisible) {
        setState(() => _faceVisible = true);
      }

      final face = faces.first;
      _updateFaceCenter(
        face,
        Size(image.width.toDouble(), image.height.toDouble()),
      );
      _evaluateTask(face);
    } catch (_) {
      // Ignore occasional ML frame errors.
    } finally {
      _processing = false;
    }
  }

  void _updateFaceCenter(Face face, Size imageSize) {
    final center = face.boundingBox.center;
    final cx = center.dx / imageSize.width;
    final cy = center.dy / imageSize.height;
    final centered = cx > 0.34 && cx < 0.66 && cy > 0.28 && cy < 0.72;
    if (centered != _faceCentered) {
      setState(() => _faceCentered = centered);
    }
  }

  void _evaluateTask(Face face) {
    if (_done || _tasks.isEmpty) return;
    final task = _tasks[_taskIndex];
    final completed = switch (task.type) {
      _LivenessTaskType.blink => _checkBlink(face),
      _LivenessTaskType.turnLeft => _checkTurn(face, isLeft: true),
      _LivenessTaskType.turnRight => _checkTurn(face, isLeft: false),
      _LivenessTaskType.smile => _checkSmile(face),
    };

    if (!completed) return;

    if (_taskIndex >= _tasks.length - 1) {
      _finish();
      return;
    }

    setState(() {
      _taskIndex += 1;
      _blinkClosed = false;
    });
  }

  bool _checkBlink(Face face) {
    final left = face.leftEyeOpenProbability ?? 1;
    final right = face.rightEyeOpenProbability ?? 1;
    final closed = left < 0.25 && right < 0.25;
    final open = left > 0.75 && right > 0.75;

    if (!_blinkClosed && closed) {
      _blinkClosed = true;
      return false;
    }
    return _blinkClosed && open;
  }

  bool _checkTurn(Face face, {required bool isLeft}) {
    final yaw = face.headEulerAngleY ?? 0;
    return isLeft ? yaw < -18 : yaw > 18;
  }

  bool _checkSmile(Face face) {
    final smile = face.smilingProbability ?? 0;
    return smile > 0.65;
  }

  InputImage _inputImageFromCameraImage(CameraImage image) {
    final WriteBuffer buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }
    final bytes = buffer.done().buffer.asUint8List();

    final size = Size(image.width.toDouble(), image.height.toDouble());
    final camera = _camera!.description;
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.rotation0deg;
    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  void _finish() {
    if (_done) return;
    setState(() => _done = true);
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final task = _tasks.isEmpty ? null : _tasks[_taskIndex];
    final theme = Theme.of(context);
    final canContinue = _faceVisible && _faceCentered;
    final statusMessage = _buildStatusMessage(t);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.livenessCheckTitle),
      ),
      body: SafeArea(
        child: _error != null
            ? _ErrorView(message: _error!, showSettings: _permissionDenied)
            : Stack(
                children: [
                  Positioned.fill(child: _buildCameraPreview()),
                  Positioned.fill(
                    child: _FaceGuideOverlay(active: canContinue),
                  ),
                  Positioned.fill(child: _GradientScrim()),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: _StatusHeader(
                      faceVisible: _faceVisible,
                      faceCentered: _faceCentered,
                      ready: _ready,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: _InstructionCard(
                      title: task?.title ?? t.livenessPreparingCamera,
                      subtitle: task?.subtitle ?? t.livenessHoldSteady,
                      stepLabel: t.livenessStepLabel(
                        _tasks.isEmpty ? 0 : _taskIndex + 1,
                        math.max(1, _tasks.length),
                      ),
                      statusMessage: statusMessage,
                      step: _tasks.isEmpty ? 0 : _taskIndex + 1,
                      total: math.max(1, _tasks.length),
                      faceVisible: _faceVisible,
                      faceCentered: _faceCentered,
                      done: _done,
                      theme: theme,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _buildStatusMessage(AppLocalizations t) {
    if (_done) return t.livenessVerifiedMessage;
    if (_faceVisible) {
      return _faceCentered
          ? t.livenessPromptHoldSteady
          : t.livenessPromptCenterFace;
    }
    return t.livenessPromptAlignFace;
  }

  Widget _buildCameraPreview() {
    if (!_ready || _camera == null || !_camera!.value.isInitialized) {
      return const Center(child: CamElectionLoader(size: 64, strokeWidth: 6));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _camera!.value.previewSize;
        if (size == null) return const SizedBox.shrink();

        final previewRatio = size.height / size.width;
        return OverflowBox(
          alignment: Alignment.center,
          maxHeight: constraints.maxHeight,
          maxWidth: constraints.maxHeight * previewRatio,
          child: CameraPreview(_camera!),
        );
      },
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.title,
    required this.subtitle,
    required this.stepLabel,
    required this.statusMessage,
    required this.step,
    required this.total,
    required this.faceVisible,
    required this.faceCentered,
    required this.done,
    required this.theme,
  });

  final String title;
  final String subtitle;
  final String stepLabel;
  final String statusMessage;
  final int step;
  final int total;
  final bool faceVisible;
  final bool faceCentered;
  final bool done;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : step / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stepLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                title,
                key: ValueKey(title),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                subtitle,
                key: ValueKey(subtitle),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CamElectionLoader(size: 18, strokeWidth: 2.4),
                const SizedBox(width: 10),
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle
                      : faceVisible && faceCentered
                      ? Icons.face_retouching_natural
                      : Icons.face_retouching_off,
                  color: done
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(160),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      statusMessage,
                      key: ValueKey(statusMessage),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.faceVisible,
    required this.faceCentered,
    required this.ready,
  });

  final bool faceVisible;
  final bool faceCentered;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final status = !ready
        ? t.livenessPreparingCamera
        : !faceVisible
        ? t.livenessStatusNoFace
        : faceCentered
        ? t.livenessStatusFaceCentered
        : t.livenessStatusAdjustPosition;

    final statusColor = !ready
        ? theme.colorScheme.outline
        : faceVisible && faceCentered
        ? BrandPalette.forest
        : BrandPalette.ember;

    Widget statusPill() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(220),
        borderRadius: BorderRadius.circular(999),
        boxShadow: BrandPalette.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              status,
              style: theme.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    Widget lightPill() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        t.livenessGoodLight,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [statusPill(), const SizedBox(height: 8), lightPill()],
          );
        }
        return Row(
          children: [
            Expanded(child: statusPill()),
            const SizedBox(width: 12),
            lightPill(),
          ],
        );
      },
    );
  }
}

class _GradientScrim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(50),
              Colors.transparent,
              Colors.black.withAlpha(160),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceGuideOverlay extends StatefulWidget {
  const _FaceGuideOverlay({required this.active});

  final bool active;

  @override
  State<_FaceGuideOverlay> createState() => _FaceGuideOverlayState();
}

class _FaceGuideOverlayState extends State<_FaceGuideOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _FaceGuidePainter(
              active: widget.active,
              pulse: _controller.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  _FaceGuidePainter({required this.active, required this.pulse});

  final bool active;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) * 0.32;

    final ringColor = active
        ? BrandPalette.forest
        : Colors.white.withAlpha(180);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = ringColor;

    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = ringColor.withAlpha((80 + (60 * pulse)).round());

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawCircle(center, radius + (10 * pulse), pulsePaint);

    final tickPaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = ringColor.withAlpha(200);

    final tick = radius * 0.25;
    _tick(
      canvas,
      center + Offset(-radius, 0),
      Offset(-radius + tick, 0),
      tickPaint,
    );
    _tick(
      canvas,
      center + Offset(radius, 0),
      Offset(radius - tick, 0),
      tickPaint,
    );
    _tick(
      canvas,
      center + Offset(0, -radius),
      Offset(0, -radius + tick),
      tickPaint,
    );
    _tick(
      canvas,
      center + Offset(0, radius),
      Offset(0, radius - tick),
      tickPaint,
    );
  }

  void _tick(Canvas canvas, Offset a, Offset b, Paint paint) {
    canvas.drawLine(a, b, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) {
    return oldDelegate.active != active || oldDelegate.pulse != pulse;
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.showSettings});

  final String message;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (showSettings) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings),
                label: Text(t.livenessOpenSettings),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _LivenessTaskType { blink, turnLeft, turnRight, smile }

class _LivenessTask {
  const _LivenessTask({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final _LivenessTaskType type;
  final String title;
  final String subtitle;

  static List<_LivenessTask> defaultSequence(AppLocalizations t) {
    final tasks = [
      _LivenessTask(
        type: _LivenessTaskType.blink,
        title: t.livenessTaskBlinkTitle,
        subtitle: t.livenessTaskBlinkSubtitle,
      ),
      _LivenessTask(
        type: _LivenessTaskType.turnLeft,
        title: t.livenessTaskTurnLeftTitle,
        subtitle: t.livenessTaskTurnLeftSubtitle,
      ),
      _LivenessTask(
        type: _LivenessTaskType.turnRight,
        title: t.livenessTaskTurnRightTitle,
        subtitle: t.livenessTaskTurnRightSubtitle,
      ),
      _LivenessTask(
        type: _LivenessTaskType.smile,
        title: t.livenessTaskSmileTitle,
        subtitle: t.livenessTaskSmileSubtitle,
      ),
    ]..shuffle(math.Random());

    return tasks.take(3).toList();
  }
}
