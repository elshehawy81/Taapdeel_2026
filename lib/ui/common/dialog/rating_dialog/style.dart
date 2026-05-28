import 'package:flutter/material.dart';

/// Controls the visual appearance of Rate-My-App dialogs.
class DialogStyle {
  /// Creates a new dialog style instance.
  ///
  /// You can override any of these values when creating the style, otherwise
  /// the defaults below will be used (good defaults for Taapdeel look & feel).
  const DialogStyle({
    this.titlePadding = const EdgeInsets.fromLTRB(24, 20, 24, 0),
    this.contentPadding = const EdgeInsets.fromLTRB(24, 16, 24, 24),
    this.titleAlign = TextAlign.start,
    this.titleStyle,
    this.messagePadding = const EdgeInsets.only(top: 8, bottom: 16),
    this.messageAlign = TextAlign.start,
    this.messageStyle,
    this.dialogShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  });

  /// Padding around the title widget.
  final EdgeInsetsGeometry titlePadding;

  /// Padding around the dialog's main content area.
  final EdgeInsetsGeometry contentPadding;

  /// Alignment of the dialog title text.
  final TextAlign? titleAlign;

  /// Text style applied to the dialog title.
  final TextStyle? titleStyle;

  /// Padding applied to the dialog message.
  final EdgeInsetsGeometry messagePadding;

  /// Alignment of the dialog message text.
  final TextAlign? messageAlign;

  /// Text style applied to the dialog message.
  final TextStyle? messageStyle;

  /// Shape of the dialog (rounded edges, borders, etc.).
  ///
  /// Defaults to a rounded rectangle with radius 16 to match Taapdeel dialogs.
  final ShapeBorder? dialogShape;
}

/// Configuration options for the star rating bar.
class StarRatingOptions {
  /// Creates a new star rating options instance.
  const StarRatingOptions({
    this.starsFillColor = Colors.orangeAccent,
    this.starsBorderColor = Colors.orangeAccent,
    this.starsSize = 40,
    this.starsSpacing = 4,
    this.initialRating = 0.0,
    this.allowHalfRating = false,
    this.halfFilledIconData = Icons.star_half,
    this.filledIconData = Icons.star,
  });

  /// The fill color of the stars.
  final Color starsFillColor;

  /// The border color of stars.
  final Color starsBorderColor;

  /// The visual size of each star.
  final double starsSize;

  /// The horizontal spacing between stars.
  final double starsSpacing;

  /// Initial rating value.
  final double initialRating;

  /// Whether half-stars are allowed.
  final bool allowHalfRating;

  /// Icon used when half of a star is filled.
  final IconData halfFilledIconData;

  /// Icon used when a full star is filled.
  final IconData filledIconData;
}
