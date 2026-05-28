import 'package:shared_preferences/shared_preferences.dart';

import 'core.dart';

/// Represents a condition that must be met for the "Rate my app" dialog to open.
abstract class Condition {
  /// Reads the condition values from the specified shared preferences.
  void readFromPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      );

  /// Saves the condition values to the specified shared preferences.
  Future<void> saveToPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      );

  /// Resets the condition values.
  void reset();

  /// Whether this condition is currently met.
  bool get isMet;

  /// Triggered when an event occurs in the plugin lifecycle.
  ///
  /// Return `true` to save the shared preferences, `false` otherwise.
  bool onEventOccurred(RateMyAppEventType eventType) => false;
}

/// A condition that can be easily inspected via a readable description.
abstract class DebuggableCondition extends Condition {
  /// Gets the condition values as a readable string.
  String get valuesAsString;
}

/// Ensures a minimum number of days has passed before showing the dialog.
class MinimumDaysCondition extends DebuggableCondition {
  MinimumDaysCondition({
    required this.minDays,
    required this.remindDays,
  });

  /// Minimum days before being able to show the dialog.
  final int minDays;

  /// Days to add to the base date when the user clicks on "Maybe later".
  final int remindDays;

  /// The minimum date required to meet this condition.
  late DateTime minimumDate;

  @override
  void readFromPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      ) {
    final int storedMillis =
        preferences.getInt('${preferencesPrefix}minimumDate') ??
            _now().millisecondsSinceEpoch;

    minimumDate = DateTime.fromMillisecondsSinceEpoch(storedMillis);
  }

  @override
  Future<void> saveToPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      ) {
    return preferences.setInt(
      '${preferencesPrefix}minimumDate',
      minimumDate.millisecondsSinceEpoch,
    );
  }

  @override
  void reset() => minimumDate = _now();

  @override
  bool get isMet => DateTime.now().isAfter(minimumDate);

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.laterButtonPressed ||
        eventType == RateMyAppEventType.iOSRequestReview) {
      // Push the minimum date forward when the user postpones rating.
      minimumDate = _now(Duration(days: remindDays));
      return true;
    }

    return false;
  }

  @override
  String get valuesAsString =>
      'Minimum days: $minDays\n'
          'Remind days: $remindDays\n'
          'Minimum valid date: ${_dateToString(minimumDate)}';

  /// Returns a formatted date string.
  String _dateToString(DateTime date) =>
      '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} '
          '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

  /// Adds a leading zero to a given number if needed.
  String _twoDigits(int number) => number.toString().padLeft(2, '0');

  /// Returns the current date with the minimum days (or custom duration) added.
  DateTime _now([Duration? toAdd]) =>
      DateTime.now().add(toAdd ?? Duration(days: minDays));
}

/// Ensures a minimum number of app launches before showing the dialog.
class MinimumAppLaunchesCondition extends DebuggableCondition {
  MinimumAppLaunchesCondition({
    required this.minLaunches,
    required this.remindLaunches,
  });

  /// Minimum launches before being able to show the dialog.
  final int minLaunches;

  /// Launches to subtract when the user clicks on "Maybe later".
  final int remindLaunches;

  /// Number of app launches.
  int launches = 0;

  @override
  void readFromPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      ) {
    launches = preferences.getInt('${preferencesPrefix}launches') ?? 0;
  }

  @override
  Future<void> saveToPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      ) {
    return preferences.setInt('${preferencesPrefix}launches', launches);
  }

  @override
  void reset() => launches = 0;

  @override
  bool get isMet => launches >= minLaunches;

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.initialized) {
      launches++;
      return true;
    }

    if (eventType == RateMyAppEventType.laterButtonPressed ||
        eventType == RateMyAppEventType.iOSRequestReview) {
      launches -= remindLaunches;
      if (launches < 0) {
        launches = 0;
      }
      return true;
    }

    return false;
  }

  @override
  String get valuesAsString =>
      'Minimum launches: $minLaunches\n'
          'Remind launches: $remindLaunches\n'
          'Current launches: $launches';
}

/// Prevents the dialog from opening again once the user has made a final choice.
class DoNotOpenAgainCondition extends DebuggableCondition {
  /// Whether the dialog should not be opened again.
  late bool doNotOpenAgain;

  @override
  void readFromPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      ) {
    doNotOpenAgain =
        preferences.getBool('${preferencesPrefix}doNotOpenAgain') ?? false;
  }

  @override
  Future<void> saveToPreferences(
      SharedPreferences preferences,
      String preferencesPrefix,
      ) {
    return preferences.setBool(
      '${preferencesPrefix}doNotOpenAgain',
      doNotOpenAgain,
    );
  }

  @override
  void reset() => doNotOpenAgain = false;

  @override
  bool get isMet => !doNotOpenAgain;

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.rateButtonPressed ||
        eventType == RateMyAppEventType.noButtonPressed) {
      doNotOpenAgain = true;
      return true;
    }

    return false;
  }

  @override
  String get valuesAsString =>
      'Do not open again? ${doNotOpenAgain ? 'Yes' : 'No'}';
}
