import 'dart:ui';

import 'package:flutter/material.dart';

class PsSquareProgressWidget extends StatelessWidget {
  const PsSquareProgressWidget({
    Key? key,
    this.size = 24,
  }) : super(key: key);

  /// Size of the square area that contains the loader.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;


    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
        ),
      ),
    );




  }
}
