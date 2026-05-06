import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final Widget? centerWidget;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.progressColor,
    this.backgroundColor = AppTheme.surfaceDim,
    this.strokeWidth = 12.0,
    this.centerWidget,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: backgroundColor,
            ),
          ),
          // Foreground Ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              color: progressColor,
              strokeCap: StrokeCap.round, // Rounded ends as per design
            ),
          ),
          if (centerWidget != null) centerWidget!,
        ],
      ),
    );
  }
}
