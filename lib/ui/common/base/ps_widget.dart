import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Base widget that wires up a [ChangeNotifier] provider
/// and exposes it to the subtree with a clean, consistent shell.
class PsWidget<T extends ChangeNotifier> extends StatefulWidget {
  const PsWidget({
    Key? key,
    required this.builder,
    required this.initProvider,
    this.child,
    this.onProviderReady,
    this.actions = const <Widget>[],
  }) : super(key: key);

  /// Screen builder that receives the provider instance.
  final Widget Function(BuildContext context, T provider, Widget? child) builder;

  /// Factory function to create the provider instance.
  final T Function() initProvider;

  /// Optional static child passed down to the [Consumer].
  final Widget? child;

  /// Optional callback invoked once after the provider is created.
  final void Function(T provider)? onProviderReady;

  /// Reserved for future use (kept for backward compatibility).
  final List<Widget> actions;

  @override
  State<PsWidget<T>> createState() => _PsWidgetState<T>();
}

class _PsWidgetState<T extends ChangeNotifier> extends State<PsWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Unified background for all screens using PsWidget
      // (Material 3 recommends using `surface` instead of `background`).
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ChangeNotifierProvider<T>(
        lazy: false,
        create: (BuildContext context) {
          final T providerObj = widget.initProvider();
          if (widget.onProviderReady != null) {
            widget.onProviderReady!(providerObj);
          }
          return providerObj;
        },
        child: SafeArea(
          child: Consumer<T>(
            builder: widget.builder,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
