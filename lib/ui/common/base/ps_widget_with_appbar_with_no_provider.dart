import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_app_bar.dart';

class PsWidgetWithAppBarWithNoProvider extends StatefulWidget {
  const PsWidgetWithAppBarWithNoProvider({
    Key? key,
    this.builder,
    required this.child,
    required this.appBarTitle,
    this.actions = const <Widget>[],
    this.showBackButton = true,
  }) : super(key: key);

  /// Optional builder that wraps the child (e.g. for layout or padding).
  final Widget Function(BuildContext context, Widget child)? builder;

  /// The content widget shown in the body.
  final Widget child;

  /// App bar title text.
  final String appBarTitle;

  /// Optional actions for the AppBar.
  final List<Widget> actions;

  /// Whether to show the back button.
  final bool showBackButton;

  @override
  State<PsWidgetWithAppBarWithNoProvider> createState() =>
      _PsWidgetWithAppBarWithNoProviderState();
}

class _PsWidgetWithAppBarWithNoProviderState
    extends State<PsWidgetWithAppBarWithNoProvider> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Build the final child based on whether a wrapper builder exists.
    final Widget finalChild = widget.builder != null
        ? widget.builder!(context, widget.child)
        : widget.child;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: TaapdeelAppBar(
        title: widget.appBarTitle,
        actions: widget.actions,
        showBackButton: widget.showBackButton,
      ),
      body: SafeArea(
        child: finalChild,
      ),
    );
  }
}
