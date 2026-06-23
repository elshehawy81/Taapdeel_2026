// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// Typically used inside [ListView] to build an expandable section.
/// Remember to give it a unique [PageStorageKey] to preserve expansion state.
class PsExpansionTile extends StatefulWidget {
  const PsExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
  }) : super(key: key);

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the list item (usually [Text]).
  final Widget title;

  /// Optional content displayed below the title.
  final Widget? subtitle;

  /// Called when the tile starts expanding (true) or collapsing (false).
  final ValueChanged<bool>? onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  final List<Widget> children;

  /// Background color behind the expanded content.
  final Color? backgroundColor;

  /// A widget to display instead of the default rotating arrow.
  final Widget? trailing;

  /// Whether the tile is initially expanded.
  final bool initiallyExpanded;

  @override
  State<PsExpansionTile> createState() => _PsExpansionTileState();
}

class _PsExpansionTileState extends State<PsExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
  CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
  CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
  Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late final AnimationController _controller;
  late final Animation<double> _heightFactor;
  late final Animation<double> _iconTurns;
  late final Animation<Color?> _headerColor;
  late final Animation<Color?> _iconColor;
  late final Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: _kExpand,
      vsync: this,
    );

    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor =
        _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded =
        PageStorage.of(context).readState(context) as bool? ??
            widget.initiallyExpanded;

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    _borderColorTween
      ..begin = Colors.transparent
      ..end = theme.dividerColor.withValues(alpha: 0.4);

    _headerColorTween
      ..begin = theme.textTheme.titleMedium?.color
      ..end = colorScheme.primary;

    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = colorScheme.primary;

    _backgroundColorTween
      ..begin = Colors.transparent
      ..end = widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });

    widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color borderSideColor =
        _borderColorTween.evaluate(_controller) ?? Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor.value ?? Colors.transparent,
        border: Border(
          top: BorderSide(color: borderSideColor),
          bottom: BorderSide(color: borderSideColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value,
            textColor: _headerColor.value,
            child: ListTile(
              onTap: _handleTap,
              leading: widget.leading,
              title: widget.title,
              subtitle: widget.subtitle,
              trailing: widget.trailing ??
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.expand_more),
                  ),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
