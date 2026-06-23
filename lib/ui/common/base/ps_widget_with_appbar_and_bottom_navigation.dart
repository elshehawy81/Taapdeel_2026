import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_app_bar.dart';
import 'package:provider/provider.dart';

class PsWidgetWithAppBarAndBottomNavigation<T extends ChangeNotifier>
    extends StatefulWidget {
  const PsWidgetWithAppBarAndBottomNavigation({
    Key? key,
    required this.builder,
    required this.initProvider,
    required this.bottonNavigationView,
    this.child,
    this.onProviderReady,
    required this.appBarTitle,
    this.actions = const <Widget>[],
    this.showBackButton = true,
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

  /// Whether to show the back button in the app bar.
  final bool showBackButton;

  /// Bottom navigation widget (e.g. BottomNavigationBar / custom nav).
  final Widget bottonNavigationView;

  @override
  State<PsWidgetWithAppBarAndBottomNavigation<T>> createState() =>
      _PsWidgetWithAppBarAndBottomNavigationState<T>();
}

class _PsWidgetWithAppBarAndBottomNavigationState<T extends ChangeNotifier>
    extends State<PsWidgetWithAppBarAndBottomNavigation<T>> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Unified background color across all screens using this shell.
      backgroundColor: colorScheme.surface,
      appBar: TaapdeelAppBar(
        title: widget.appBarTitle,
        actions: widget.actions,
        showBackButton: widget.showBackButton,
      ),
      bottomNavigationBar: widget.bottonNavigationView,
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
          top: false, // AppBar already handles the top inset.
          child: Consumer<T>(
            builder: widget.builder,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
