import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'conditions.dart';
import 'dialogs.dart';
import 'style.dart';

/// Allows to kindly ask users to rate the app when custom conditions are met
/// (install time, number of launches, etc.).
class RateMyApp {
  /// Creates a new Rate my app instance with default conditions.
  RateMyApp({
    this.preferencesPrefix = 'rateMyApp_',
    int? minDays,
    int? remindDays,
    int? minLaunches,
    int? remindLaunches,
    this.googlePlayIdentifier,
    this.appStoreIdentifier,
  }) : conditions = <Condition>[] {
    populateWithDefaultConditions(
      minDays: minDays,
      remindDays: remindDays,
      minLaunches: minLaunches,
      remindLaunches: remindLaunches,
    );
  }

  /// Creates a new Rate my app instance with custom conditions.
  const RateMyApp.customConditions({
    this.preferencesPrefix = 'rateMyApp_',
    this.googlePlayIdentifier,
    this.appStoreIdentifier,
    required this.conditions,
  });

  /// Plugin method channel.
  static const MethodChannel _channel = MethodChannel('rate_my_app');

  /// Prefix for SharedPreferences keys.
  final String preferencesPrefix;

  /// Google Play identifier (Android package name).
  final String? googlePlayIdentifier;

  /// App Store identifier.
  final String? appStoreIdentifier;

  /// All conditions that must be met to show the dialog.
  final List<Condition> conditions;

  /// Initializes the plugin (loads conditions from SharedPreferences).
  Future<void> init() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    for (final Condition condition in conditions) {
      condition.readFromPreferences(preferences, preferencesPrefix);
    }

    await callEvent(RateMyAppEventType.initialized);
  }

  /// Saves current state to SharedPreferences.
  Future<void> save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    for (final Condition condition in conditions) {
      await condition.saveToPreferences(preferences, preferencesPrefix);
    }

    await callEvent(RateMyAppEventType.saved);
  }

  /// Resets all conditions and persists the reset state.
  Future<void> reset() async {
    for (final Condition condition in conditions) {
      condition.reset();
    }

    await save();
  }

  /// Whether all conditions are met and the dialog can be shown.
  bool get shouldOpenDialog =>
      conditions.every((Condition condition) => condition.isMet);

  /// Returns the appropriate store identifier for the current platform.
  String? get storeIdentifier {
    if (Platform.isIOS) {
      return appStoreIdentifier;
    }
    if (Platform.isAndroid) {
      return googlePlayIdentifier;
    }
    return null;
  }

  /// Returns whether native review dialog is supported on this platform.
  Future<bool?> get isNativeReviewDialogSupported =>
      _channel.invokeMethod<bool>('isNativeDialogSupported');

  /// Launches the native review dialog.
  ///
  /// You should check [isNativeReviewDialogSupported] before calling this.
  Future<void> launchNativeReviewDialog() =>
      _channel.invokeMethod<void>('launchNativeReviewDialog');

  /// Shows the standard "rate this app" dialog.
  Future<void> showRateDialog(
      BuildContext context, {
        String? title,
        String? message,
        DialogContentBuilder? contentBuilder,
        DialogActionsBuilder? actionsBuilder,
        String? rateButton,
        String? noButton,
        String? laterButton,
        RateMyAppDialogButtonClickListener? listener,
        bool? ignoreNativeDialog,
        DialogStyle? dialogStyle,
        VoidCallback? onDismissed,
      }) async {
    // On Android we usually skip the native dialog and show our custom one.
    ignoreNativeDialog ??= Platform.isAndroid;

    final bool nativeSupported =
        (await isNativeReviewDialogSupported) ?? false;

    if (!ignoreNativeDialog && nativeSupported) {
      await callEvent(RateMyAppEventType.iOSRequestReview);
      await launchNativeReviewDialog();
      return;
    }

    await callEvent(RateMyAppEventType.dialogOpen);

    final RateMyAppDialogButton? clickedButton =
    await showDialog<RateMyAppDialogButton>(
      context: context,
      builder: (BuildContext context) => RateMyAppDialog(
        this,
        title: title ?? 'Rate this app',
        message: message ??
            'If you like this app, please take a little bit of your time to review it!\n'
                'It really helps us and it shouldn\'t take you more than one minute.',
        contentBuilder:
        contentBuilder ??
                (BuildContext context, Widget defaultContent) =>
            defaultContent,
        actionsBuilder: actionsBuilder,
        rateButton: rateButton ?? 'RATE',
        noButton: noButton ?? 'NO THANKS',
        laterButton: laterButton ?? 'MAYBE LATER',
        listener: listener,
        dialogStyle: dialogStyle ?? const DialogStyle(),
      ),
    );

    // Dialog was dismissed by back button / tap outside.
    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
  }

  /// Shows the star rating dialog.
  Future<void> showStarRateDialog(
      BuildContext context, {
        String? title,
        String? message,
        DialogContentBuilder? contentBuilder,
        StarDialogActionsBuilder? actionsBuilder,
        bool? ignoreNativeDialog,
        DialogStyle? dialogStyle,
        StarRatingOptions? starRatingOptions,
        VoidCallback? onDismissed,
      }) async {
    // On Android we usually skip the native dialog and show our custom one.
    ignoreNativeDialog ??= Platform.isAndroid;

    final bool nativeSupported =
        (await isNativeReviewDialogSupported) ?? false;

    if (!ignoreNativeDialog && nativeSupported) {
      await callEvent(RateMyAppEventType.iOSRequestReview);
      await launchNativeReviewDialog();
      return;
    }

    assert(
    actionsBuilder != null,
    'You should provide an actions builder for the star dialog.',
    );

    await callEvent(RateMyAppEventType.starDialogOpen);

    final RateMyAppDialogButton? clickedButton =
    await showDialog<RateMyAppDialogButton>(
      context: context,
      builder: (BuildContext context) => RateMyAppStarDialog(
        this,
        title: title ?? 'Rate this app',
        message: message ??
            'Do you like this app? Take a moment to leave a rating:',
        contentBuilder:
        contentBuilder ??
                (BuildContext context, Widget defaultContent) =>
            defaultContent,
        actionsBuilder: actionsBuilder,
        dialogStyle: dialogStyle ??
            const DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 20),
            ),
        starRatingOptions: starRatingOptions ?? const StarRatingOptions(),
      ),
    );

    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
  }

  /// Opens the corresponding store page for this app.
  Future<LaunchStoreResult> launchStore() async {
    final int? result = await _channel.invokeMethod<int>(
      'launchStore',
      storeIdentifier == null
          ? null
          : <String, dynamic>{'appId': storeIdentifier},
    );

    switch (result) {
      case 0:
        return LaunchStoreResult.storeOpened;
      case 1:
        return LaunchStoreResult.browserOpened;
      default:
        return LaunchStoreResult.errorOccurred;
    }
  }

  /// Dispatches an event to all conditions and persists if needed.
  Future<void> callEvent(RateMyAppEventType eventType) async {
    bool shouldSavePrefs = false;

    for (final Condition condition in conditions) {
      final bool conditionWantsSave =
      condition.onEventOccurred(eventType);
      shouldSavePrefs = conditionWantsSave || shouldSavePrefs;
    }

    if (shouldSavePrefs) {
      await save();
    }
  }

  /// Adds the default conditions to the current conditions list.
  void populateWithDefaultConditions({
    int? minDays,
    int? remindDays,
    int? minLaunches,
    int? remindLaunches,
  }) {
    conditions.add(
      MinimumDaysCondition(
        minDays: minDays ?? 7,
        remindDays: remindDays ?? 7,
      ),
    );
    conditions.add(
      MinimumAppLaunchesCondition(
        minLaunches: minLaunches ?? 10,
        remindLaunches: remindLaunches ?? 10,
      ),
    );
    conditions.add(DoNotOpenAgainCondition());
  }
}

/// All events that can occur during the Rate my app lifecycle.
enum RateMyAppEventType {
  /// When Rate my app is fully initialized.
  initialized,

  /// When Rate my app state has been saved.
  saved,

  /// When a native iOS rating dialog will be requested.
  iOSRequestReview,

  /// When the classic Rate my app dialog will be opened.
  dialogOpen,

  /// When the star dialog will be opened.
  starDialogOpen,

  /// When the rate button has been pressed.
  rateButtonPressed,

  /// When the later button has been pressed.
  laterButtonPressed,

  /// When the no button has been pressed.
  noButtonPressed,
}

/// Result of the [launchStore] method.
enum LaunchStoreResult {
  /// The store has been opened successfully.
  storeOpened,

  /// The store has not been opened, but a browser link was opened instead.
  browserOpened,

  /// An error occurred and nothing was opened.
  errorOccurred,
}
