import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/dialog/rating_dialog/core.dart';

/// Called once RateMyApp has been initialized.
typedef RateMyAppInitializedCallback = void Function(
    BuildContext context,
    RateMyApp rateMyApp,
    );

/// Builds a widget and initializes RateMyApp once per app launch.
class RateMyAppBuilder extends StatefulWidget {
  const RateMyAppBuilder({
    Key? key,
    required this.builder,
    this.rateMyApp,
    this.onInitialized,
  }) : super(key: key);

  /// Widget builder for the subtree.
  final WidgetBuilder builder;

  /// Optional existing RateMyApp instance.
  final RateMyApp? rateMyApp;

  /// Called after RateMyApp is initialized.
  final RateMyAppInitializedCallback? onInitialized;

  @override
  State<RateMyAppBuilder> createState() => _RateMyAppBuilderState();
}

class _RateMyAppBuilderState extends State<RateMyAppBuilder> {
  late final RateMyApp _rateMyApp;

  @override
  void initState() {
    super.initState();
    _rateMyApp = widget.rateMyApp ?? RateMyApp();
    _initRateMyApp();
  }

  /// Initializes RateMyApp once per app launch.
  Future<void> _initRateMyApp() async {
    await _rateMyApp.init();

    if (widget.onInitialized != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInitialized!(context, _rateMyApp);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
