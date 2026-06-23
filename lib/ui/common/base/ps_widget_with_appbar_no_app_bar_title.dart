import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PsWidgetWithAppBarNoAppBarTitle<T extends ChangeNotifier>
    extends StatefulWidget {
  const PsWidgetWithAppBarNoAppBarTitle({
    Key? key,
    required this.builder,
    required this.initProvider,
    this.child,
    this.onProviderReady,
  }) : super(key: key);

  /// Screen builder that receives the provider instance.
  final Widget Function(BuildContext context, T provider, Widget? child) builder;

  /// Factory function to create the provider instance.
  final T Function() initProvider;

  /// Optional static child passed down to the [Consumer].
  final Widget? child;

  /// Optional callback invoked once after the provider is created.
  final void Function(T provider)? onProviderReady;

  @override
  State<PsWidgetWithAppBarNoAppBarTitle<T>> createState() =>
      _PsWidgetWithAppBarNoAppBarTitleState<T>();
}

class _PsWidgetWithAppBarNoAppBarTitleState<T extends ChangeNotifier>
    extends State<PsWidgetWithAppBarNoAppBarTitle<T>> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      // Unified background with the rest of the app (Material 3 surface).
      backgroundColor: colorScheme.surface,
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
