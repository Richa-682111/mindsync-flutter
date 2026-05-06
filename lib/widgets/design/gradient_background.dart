import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final PreferredSizeWidget? appBar;

  const GradientBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: useSafeArea ? SafeArea(child: child) : child,
      ),
    );
  }
}
