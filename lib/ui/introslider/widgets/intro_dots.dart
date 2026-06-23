import 'package:flutter/material.dart';

class IntroDots extends StatelessWidget {
  final int current;
  const IntroDots({Key? key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF0FA3A6)
                : Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
