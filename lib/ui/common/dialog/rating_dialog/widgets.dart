import 'package:flutter/material.dart';

import 'core.dart';

/// Callback triggered once [RateMyApp] is fully initialized.
typedef RateMyAppInitializedCallback = void Function(
    BuildContext context,
    RateMyApp? rateMyApp,
    );

/// A stateful helper widget that:
/// 1) Initializes [RateMyApp] once,
/// 2) Then builds the provided widget tree.
///
/// Useful to centralize "rate my app" initialization at app start.
class RateMyAppBuilder extends StatefulWidget {
  const RateMyAppBuilder({
    Key? key,
    required this.builder,
    this.rateMyApp,
    this.onInitialized,
  }) : super(key: key);

  /// The widget to build once initialization completes.
  ///
  /// Note: this builder does not depend on [RateMyApp] directly.
  /// Use [onInitialized] if you want to open dialogs, etc.
  final WidgetBuilder builder;

  /// Optional [RateMyApp] instance.
  ///
  /// If null, a new instance will be created with default conditions.
  final RateMyApp? rateMyApp;

  /// Callback fired after [RateMyApp] has been initialized.
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
    _initialize();
  }

  /// Initializes [RateMyApp] once per app launch.
  Future<void> _initialize() async {
    await _rateMyApp.init();

    if (!mounted) {
      return;
    }

    if (widget.onInitialized != null) {
      // Run after the first frame so context is fully ready
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
