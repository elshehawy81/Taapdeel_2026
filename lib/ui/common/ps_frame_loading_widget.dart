import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

class PsFrameUIForLoading extends StatelessWidget {
  const PsFrameUIForLoading({
    Key? key,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 16,
  }) : super(key: key);

  final double height;
  final double width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ShimmerOverlay(
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.all(PsDimens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PREMIUM SHIMMER EFFECT
/// ---------------------------------------------------------------------------

class ShimmerOverlay extends StatefulWidget {
  const ShimmerOverlay({
    Key? key,
    required this.child,
    this.shimmerColor,
    this.baseColor,
  }) : super(key: key);

  final Widget child;

  /// color of the moving highlight
  final Color? shimmerColor;

  /// base background color
  final Color? baseColor;

  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment(-1 - _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: <Color>[
                widget.baseColor ?? cs.surfaceContainerHighest.withValues(alpha: 0.30),
                widget.shimmerColor ?? cs.primary.withValues(alpha: 0.12),
                widget.baseColor ?? cs.surfaceContainerHighest.withValues(alpha: 0.30),
              ],
              stops: const <double>[0.1, 0.5, 0.9],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
