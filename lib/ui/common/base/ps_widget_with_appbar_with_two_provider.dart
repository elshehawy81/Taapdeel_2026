import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class PsWidgetWithAppBarWithTwoProvider<
T extends ChangeNotifier,
V extends ChangeNotifier> extends StatefulWidget {
  const PsWidgetWithAppBarWithTwoProvider({
    Key? key,
    required this.initProvider1,
    required this.initProvider2,
    this.child,
    this.onProviderReady1,
    this.onProviderReady2,
    required this.appBarTitle,
    this.actions = const <Widget>[],
    this.showBackButton = true,
  }) : super(key: key);

  /// Provider constructors
  final T Function() initProvider1;
  final V Function() initProvider2;

  /// Optional callbacks executed after provider creation
  final void Function(T provider)? onProviderReady1;
  final void Function(V provider)? onProviderReady2;

  /// Child content widget
  final Widget? child;

  /// AppBar settings
  final String appBarTitle;
  final List<Widget> actions;
  final bool showBackButton;

  @override
  State<PsWidgetWithAppBarWithTwoProvider<T, V>> createState() =>
      _PsWidgetWithAppBarWithTwoProviderState<T, V>();
}

class _PsWidgetWithAppBarWithTwoProviderState<
T extends ChangeNotifier,
V extends ChangeNotifier>
    extends State<PsWidgetWithAppBarWithTwoProvider<T, V>> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      /// Premium unified Taapdeel AppBar
      appBar: TaapdeelAppBar(
        title: widget.appBarTitle,
        actions: widget.actions,
        showBackButton: widget.showBackButton,
      ),

      body: SafeArea(
        child: MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<T>(
              lazy: false,
              create: (BuildContext context) {
                final T provider1 = widget.initProvider1();
                if (widget.onProviderReady1 != null) {
                  widget.onProviderReady1!(provider1);
                }
                return provider1;
              },
            ),
            ChangeNotifierProvider<V>(
              lazy: false,
              create: (BuildContext context) {
                final V provider2 = widget.initProvider2();
                if (widget.onProviderReady2 != null) {
                  widget.onProviderReady2!(provider2);
                }
                return provider2;
              },
            ),
          ],
          child: widget.child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
