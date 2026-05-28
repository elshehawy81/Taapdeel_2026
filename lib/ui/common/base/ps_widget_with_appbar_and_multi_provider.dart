import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_app_bar.dart';

class PsWidgetWithAppBarAndMultiProvider extends StatefulWidget {
  const PsWidgetWithAppBarAndMultiProvider({
    Key? key,
    this.child,
    required this.appBarTitle,
    this.actions = const <Widget>[],
  }) : super(key: key);

  final Widget? child;
  final String appBarTitle;
  final List<Widget> actions;

  @override
  State<PsWidgetWithAppBarAndMultiProvider> createState() =>
      _PsWidgetWithAppBarAndMultiProviderState();
}

class _PsWidgetWithAppBarAndMultiProviderState
    extends State<PsWidgetWithAppBarAndMultiProvider> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      // Unified background with the rest of the app (Material 3 surface).
      backgroundColor: colorScheme.surface,
      appBar: TaapdeelAppBar(
        title: widget.appBarTitle,
        actions: widget.actions,
      ),
      body: SafeArea(
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }
}
