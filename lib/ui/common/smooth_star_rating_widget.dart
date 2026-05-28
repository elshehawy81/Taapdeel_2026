import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef RatingChangeCallback = void Function(double? rating);

class SmoothStarRating extends StatefulWidget {
  const SmoothStarRating({
    Key? key,
    this.isRTl,
    this.starCount = 5,
    this.isReadOnly = false,
    this.spacing = 0.0,
    this.rating = 0.0,
    this.defaultIconData = Icons.star_border,
    this.onRated,
    this.color,
    this.borderColor,
    this.size = 25,
    this.filledIconData = Icons.star,
    this.halfFilledIconData = Icons.star_half,
    this.allowHalfRating = true,
  }) : super(key: key);

  final int starCount;
  final double rating;
  final bool? isRTl;
  final RatingChangeCallback? onRated;
  final Color? color;
  final Color? borderColor;
  final double size;
  final bool allowHalfRating;
  final IconData filledIconData;
  final IconData halfFilledIconData;

  /// Default icon when not filled.
  final IconData defaultIconData;

  final double spacing;
  final bool isReadOnly;

  @override
  State<SmoothStarRating> createState() => _SmoothStarRatingState();
}

class _SmoothStarRatingState extends State<SmoothStarRating> {
  /// Half star value starts from this number.
  static const double halfStarThreshold = 0.53;

  /// Tracks if the user tapped/dragged on this widget (vs only hovered on web).
  bool isWidgetTapped = false;

  late double currentRating;
  Timer? debounceTimer;

  bool get _isRtl => widget.isRTl ?? false;

  @override
  void initState() {
    super.initState();
    currentRating = widget.rating;
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: widget.spacing,
        children: List<Widget>.generate(
          widget.starCount,
              (int index) => _buildStar(context, index),
        ),
      ),
    );
  }

  Widget _buildStar(BuildContext context, int index) {
    final Icon icon;
    if (index >= currentRating) {
      icon = Icon(
        widget.defaultIconData,
        color: widget.borderColor ?? Theme.of(context).primaryColor,
        size: widget.size,
      );
    } else if (index >=
        currentRating -
            (widget.allowHalfRating ? halfStarThreshold : 1.0) &&
        index < currentRating) {
      icon = Icon(
        widget.halfFilledIconData,
        color: widget.color ?? Theme.of(context).primaryColor,
        size: widget.size,
      );
    } else {
      icon = Icon(
        widget.filledIconData,
        color: widget.color ?? Theme.of(context).primaryColor,
        size: widget.size,
      );
    }

    if (widget.isReadOnly) {
      return icon;
    }

    final Widget starChild = kIsWeb
        ? _buildInteractiveStarWeb(context, icon)
        : _buildInteractiveStarMobile(context, icon);

    return starChild;
  }

  Widget _buildInteractiveStarWeb(BuildContext context, Icon icon) {
    return MouseRegion(
      onExit: (PointerExitEvent event) {
        if (widget.onRated != null && !isWidgetTapped) {
          setState(() {
            currentRating = 0;
          });
        }
      },
      onEnter: (PointerEnterEvent event) {
        isWidgetTapped = false;
      },
      onHover: (PointerHoverEvent event) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset pos = box.globalToLocal(event.position);
        double newRating = pos.dx / widget.size;
        newRating = _clampRating(newRating);

        setState(() {
          currentRating = _isRtl
              ? widget.starCount - newRating
              : newRating;
        });
      },
      child: GestureDetector(
        onTapDown: (TapDownDetails detail) {
          isWidgetTapped = true;

          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset pos = box.globalToLocal(detail.globalPosition);
          double newRating = (pos.dx - widget.spacing) / widget.size;
          newRating = _clampRating(newRating);

          setState(() {
            currentRating = _isRtl
                ? widget.starCount - newRating
                : newRating;
          });

          widget.onRated?.call(currentRating);
        },
        onHorizontalDragUpdate: (DragUpdateDetails dragDetails) {
          isWidgetTapped = true;

          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset pos =
          box.globalToLocal(dragDetails.globalPosition);
          double newRating = pos.dx / widget.size;
          newRating = _clampRating(newRating);

          setState(() {
            currentRating = _isRtl
                ? widget.starCount - newRating
                : newRating;
          });

          debounceTimer?.cancel();
          debounceTimer = Timer(const Duration(milliseconds: 100), () {
            widget.onRated?.call(currentRating);
          });
        },
        child: icon,
      ),
    );
  }

  Widget _buildInteractiveStarMobile(BuildContext context, Icon icon) {
    return GestureDetector(
      onTapDown: (TapDownDetails detail) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset pos = box.globalToLocal(detail.globalPosition);
        double newRating = (pos.dx - widget.spacing) / widget.size;
        newRating = _clampRating(newRating);
        newRating = _normalizeRating(newRating);

        setState(() {
          currentRating =
          _isRtl ? widget.starCount - newRating : newRating;
        });
      },
      onTapUp: (TapUpDetails e) {
        widget.onRated?.call(currentRating);
      },
      onHorizontalDragUpdate: (DragUpdateDetails dragDetails) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset pos = box.globalToLocal(dragDetails.globalPosition);
        double newRating = pos.dx / widget.size;
        newRating = _clampRating(newRating);

        setState(() {
          currentRating =
          _isRtl ? widget.starCount - newRating : newRating;
        });

        debounceTimer?.cancel();
        debounceTimer = Timer(const Duration(milliseconds: 100), () {
          widget.onRated?.call(currentRating);
        });
      },
      child: icon,
    );
  }

  double _clampRating(double value) {
    double newRating =
    widget.allowHalfRating ? value : value.round().toDouble();
    if (newRating > widget.starCount) {
      newRating = widget.starCount.toDouble();
    }
    if (newRating < 0) {
      newRating = 0.0;
    }
    return newRating;
  }

  double _normalizeRating(double newRating) {
    final double fraction = newRating - newRating.floor();
    if (fraction != 0) {
      if (fraction >= halfStarThreshold) {
        newRating = newRating.floor() + 1.0;
      } else {
        newRating = newRating.floor() + 0.5;
      }
    }
    return newRating;
  }
}
