import 'package:flutter/material.dart';

class PsWidgetWithMultiProvider extends StatefulWidget {
  const PsWidgetWithMultiProvider({
    Key? key,
    this.child,
  }) : super(key: key);

  /// The child widget wrapped by multi providers outside.
  final Widget? child;

  @override
  State<PsWidgetWithMultiProvider> createState() =>
      _PsWidgetWithMultiProviderState();
}

class _PsWidgetWithMultiProviderState
    extends State<PsWidgetWithMultiProvider> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }
}
