import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/dialog/rating_dialog/core.dart';
import 'package:taapdeel/ui/common/dialog/rating_dialog/style.dart';

import '../smooth_star_rating_widget.dart';

typedef RateMyAppDialogButtonClickListener = bool Function(
    RateMyAppDialogButton button,
    );

typedef Validator = bool Function();

typedef DialogContentBuilder = Widget Function(
    BuildContext context,
    Widget defaultContent,
    );

typedef DialogActionsBuilder = List<Widget> Function(
    BuildContext context,
    );

typedef StarDialogActionsBuilder = List<Widget> Function(
    BuildContext context,
    double? stars,
    );

class RateMyAppDialog extends StatelessWidget {
  const RateMyAppDialog(
      this.rateMyApp, {
        Key? key,
        required this.title,
        required this.message,
        required this.contentBuilder,
        this.actionsBuilder,
        required this.rateButton,
        required this.noButton,
        required this.laterButton,
        this.listener,
        required this.dialogStyle,
      }) : super(key: key);

  final RateMyApp rateMyApp;
  final String title;
  final String message;
  final DialogContentBuilder contentBuilder;
  final DialogActionsBuilder? actionsBuilder;
  final String rateButton;
  final String noButton;
  final String laterButton;
  final RateMyAppDialogButtonClickListener? listener;
  final DialogStyle dialogStyle;

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Widget defaultContent = SingleChildScrollView(
      child: Padding(
        padding: dialogStyle.messagePadding,
        child: Text(
          message,
          style: dialogStyle.messageStyle,
          textAlign: dialogStyle.messageAlign,
        ),
      ),
    );

    final List<Widget> actions =
    (actionsBuilder ?? _defaultActionsBuilder)(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space24,
        vertical: PsDimens.space24,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: (Theme.of(context).dialogTheme.backgroundColor ??
                PsColors.baseLightColor)
                .withValues(alpha: isDark ? 0.96 : 0.98),
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: (dialogStyle.contentPadding.horizontal +
              dialogStyle.contentPadding.vertical) >
              0
              ? dialogStyle.contentPadding
              : const EdgeInsets.all(PsDimens.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Title
              Padding(
                padding: dialogStyle.titlePadding,
                child: Text(
                  title,
                  style: dialogStyle.titleStyle,
                  textAlign: dialogStyle.titleAlign,
                ),
              ),

              const SizedBox(height: PsDimens.space8),

              // Content
              contentBuilder(context, defaultContent),

              const SizedBox(height: PsDimens.space16),

              // Actions aligned to the end (like Material dialogs)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: actions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _defaultActionsBuilder(BuildContext context) => <Widget>[
    RateMyAppRateButton(
      rateMyApp,
      text: rateButton,
      validator: () =>
      listener == null || listener!(RateMyAppDialogButton.rate),
    ),
    RateMyAppLaterButton(
      rateMyApp,
      text: laterButton,
      validator: () =>
      listener == null || listener!(RateMyAppDialogButton.later),
    ),
    RateMyAppNoButton(
      rateMyApp,
      text: noButton,
      validator: () =>
      listener == null || listener!(RateMyAppDialogButton.no),
    ),
  ];
}

class RateMyAppStarDialog extends StatefulWidget {
  const RateMyAppStarDialog(
      this.rateMyApp, {
        Key? key,
        required this.title,
        required this.message,
        required this.contentBuilder,
        this.actionsBuilder,
        required this.dialogStyle,
        required this.starRatingOptions,
      }) : super(key: key);

  final RateMyApp rateMyApp;
  final String title;
  final String message;
  final DialogContentBuilder contentBuilder;
  final StarDialogActionsBuilder? actionsBuilder;
  final DialogStyle dialogStyle;
  final StarRatingOptions starRatingOptions;

  @override
  State<RateMyAppStarDialog> createState() => RateMyAppStarDialogState();

  List<Widget> _defaultOnRatingChanged(
      BuildContext context,
      double? rating,
      ) =>
      <Widget>[
        RateMyAppRateButton(
          rateMyApp,
          text: 'RATE',
        ),
        RateMyAppLaterButton(
          rateMyApp,
          text: 'MAYBE LATER',
        ),
        RateMyAppNoButton(
          rateMyApp,
          text: 'NO',
        ),
      ];
}

class RateMyAppStarDialogState extends State<RateMyAppStarDialog> {
  double? _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.starRatingOptions.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Widget defaultContent = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: widget.dialogStyle.messagePadding,
            child: Text(
              widget.message,
              style: widget.dialogStyle.messageStyle,
              textAlign: widget.dialogStyle.messageAlign,
            ),
          ),
          SmoothStarRating(
            onRated: (double? rating) {
              setState(() => _currentRating = rating);
            },
            color: widget.starRatingOptions.starsFillColor,
            borderColor: widget.starRatingOptions.starsBorderColor,
            spacing: widget.starRatingOptions.starsSpacing,
            size: widget.starRatingOptions.starsSize,
            allowHalfRating: widget.starRatingOptions.allowHalfRating,
            halfFilledIconData: widget.starRatingOptions.halfFilledIconData,
            filledIconData: widget.starRatingOptions.filledIconData,
            rating: _currentRating?.toDouble() ?? 0.0,
          ),
        ],
      ),
    );

    final List<Widget> actions =
    (widget.actionsBuilder ?? widget._defaultOnRatingChanged)(
      context,
      _currentRating,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space24,
        vertical: PsDimens.space24,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: (Theme.of(context).dialogTheme.backgroundColor ??
                PsColors.baseLightColor)
                .withValues(alpha: isDark ? 0.96 : 0.98),
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: (widget.dialogStyle.contentPadding.horizontal +
              widget.dialogStyle.contentPadding.vertical) >
              0
              ? widget.dialogStyle.contentPadding
              : const EdgeInsets.all(PsDimens.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Title
              Padding(
                padding: widget.dialogStyle.titlePadding,
                child: Text(
                  widget.title,
                  style: widget.dialogStyle.titleStyle,
                  textAlign: widget.dialogStyle.titleAlign,
                ),
              ),

              const SizedBox(height: PsDimens.space8),

              // Content (message + stars)
              widget.contentBuilder(context, defaultContent),

              const SizedBox(height: PsDimens.space16),

              // Actions
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: actions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class _RateMyAppDialogButton extends StatelessWidget {
  const _RateMyAppDialogButton(
      this.rateMyApp, {
        Key? key,
        required this.text,
        this.validator = _validatorTrue,
        this.callback,
      }) : super(key: key);

  final RateMyApp rateMyApp;
  final String text;
  final Validator? validator;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      if (validator != null && !validator!()) {
        return;
      }

      await onButtonClicked(context);
      if (callback != null) {
        callback!();
      }
    },
    child: Text(text),
  );

  Future<void> onButtonClicked(BuildContext context);

  static bool _validatorTrue() => true;
}

class RateMyAppRateButton extends _RateMyAppDialogButton {
  const RateMyAppRateButton(
      RateMyApp rateMyApp, {
        Key? key,
        required String text,
        Validator? validator,
        VoidCallback? callback,
      }) : super(
    rateMyApp,
    key: key,
    text: text,
    validator: validator,
    callback: callback,
  );

  @override
  Future<void> onButtonClicked(BuildContext context) async {
    await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
    Navigator.pop<RateMyAppDialogButton>(
      context,
      RateMyAppDialogButton.rate,
    );
    await rateMyApp.launchStore();
  }
}

class RateMyAppLaterButton extends _RateMyAppDialogButton {
  const RateMyAppLaterButton(
      RateMyApp rateMyApp, {
        Key? key,
        required String text,
        Validator? validator,
        VoidCallback? callback,
      }) : super(
    rateMyApp,
    key: key,
    text: text,
    validator: validator,
    callback: callback,
  );

  @override
  Future<void> onButtonClicked(BuildContext context) async {
    await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
    Navigator.pop<RateMyAppDialogButton>(
      context,
      RateMyAppDialogButton.later,
    );
  }
}

class RateMyAppNoButton extends _RateMyAppDialogButton {
  const RateMyAppNoButton(
      RateMyApp rateMyApp, {
        Key? key,
        required String text,
        Validator? validator,
        VoidCallback? callback,
      }) : super(
    rateMyApp,
    key: key,
    text: text,
    validator: validator,
    callback: callback,
  );

  @override
  Future<void> onButtonClicked(BuildContext context) async {
    await rateMyApp.callEvent(RateMyAppEventType.noButtonPressed);
    Navigator.pop<RateMyAppDialogButton>(
      context,
      RateMyAppDialogButton.no,
    );
  }
}

enum RateMyAppDialogButton {
  rate,
  later,
  no,
}
