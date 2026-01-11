import 'package:flutter/material.dart';
import '../../theme/cam_colors.dart';

/// Beautiful animated loader with Cameroon flag colors
/// Displays rotating flag bars to indicate loading state
class CamElectionLoader extends StatefulWidget {
  final String? message;
  
  const CamElectionLoader({
    super.key,
    this.message,
  });

  @override
  State<CamElectionLoader> createState() => _CamElectionLoaderState();
}

class _CamElectionLoaderState extends State<CamElectionLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Cameroon flag color bars
          RotationTransition(
            turns: _controller,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: CamColors.green,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(color: CamColors.red),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: CamColors.yellow,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: 16,
                color: CamColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}