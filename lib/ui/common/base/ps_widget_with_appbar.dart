import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_app_bar.dart';
import 'package:provider/provider.dart';

class PsWidgetWithAppBar<T extends ChangeNotifier> extends StatefulWidget {
  const PsWidgetWithAppBar({
    Key? key,
    required this.builder,
    required this.initProvider,
    this.child,
    this.onProviderReady,
    required this.appBarTitle,
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

  /// App bar title text.
  final String appBarTitle;

  /// Optional actions to show in the app bar.
  final List<Widget> actions;

  @override
  State<PsWidgetWithAppBar<T>> createState() => _PsWidgetWithAppBarState<T>();
}

class _PsWidgetWithAppBarState<T extends ChangeNotifier>
    extends State<PsWidgetWithAppBar<T>> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      // Unified background color across all screens with app bar.
      backgroundColor: colorScheme.surface,
      appBar: TaapdeelAppBar(
        title: widget.appBarTitle,

        actions: widget.actions,
      ),
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
          top: false,
          child: Consumer<T>(
            builder: widget.builder,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
