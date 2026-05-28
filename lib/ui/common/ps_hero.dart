import 'package:flutter/material.dart';

class PsHero extends StatelessWidget {
  const PsHero({
    Key? key,
    required this.tag,
    required this.child,
    this.flightShuttleBuilder,
    this.transitionOnUserGestures = false,
    this.enabled = true,
  }) : super(key: key);

  final String tag;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final bool transitionOnUserGestures;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    // ✅ Prevent: Hero inside Hero
    final hasAncestorHero = context.findAncestorWidgetOfExactType<Hero>() != null;
    if (hasAncestorHero) return child;

    return Hero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: child,
    );
  }
}
