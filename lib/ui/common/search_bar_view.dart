// Copyright (c) 2017, Spencer. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';

typedef AppBarCallback = AppBar Function(BuildContext context);
typedef TextFieldSubmitCallback = void Function(String value);
typedef TextFieldChangeCallback = void Function(String value);
// ignore: prefer_generic_function_type_aliases
typedef void SetStateCallback(void fn());

class SearchBarWidget {

  SearchBarWidget({
    required this.setState,
    required this.buildDefaultAppBar,
    this.tabBar,
    this.onSubmitted,
    this.controller,
    this.hintText = 'Search',
    this.inBar = true,
    this.closeOnSubmit = true,
    this.clearOnSubmit = true,
    this.showClearButton = true,
    this.onChanged,
    this.onClosed,
    this.onCleared,
  }) {
    controller ??= TextEditingController();

    if (!showClearButton) {
      return;
    }

    controller!.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (controller!.text.isEmpty) {
      if (_clearActive) {
        setState(() {
          _clearActive = false;
        });
      }
      return;
    }

    if (!_clearActive) {
      setState(() {
        _clearActive = true;
      });
    }
  }

  void dispose() {
    isSearching.dispose();
    controller?.removeListener(_onControllerChanged);
  }

  /// Whether the search is shown in the same bar background or not.
  final bool inBar;

  /// Whether or not the search bar should close on submit. Defaults to true.
  final bool closeOnSubmit;

  /// Whether the text field should be cleared when it is submitted.
  final bool clearOnSubmit;

  /// Builder for the default AppBar shown before search starts.
  /// One of the actions should call [getSearchAction].
  final AppBarCallback buildDefaultAppBar;

  /// Callback fired every time the search is submitted.
  final TextFieldSubmitCallback? onSubmitted;

  /// Callback fired when the search bar is closed.
  final VoidCallback? onClosed;

  /// Callback fired when the clear button is pressed.
  final VoidCallback? onCleared;

  /// Pass `setState` from the owning State.
  final SetStateCallback setState;

  /// Whether or not a clear input button should be shown. Defaults to true.
  final bool showClearButton;

  /// Hint text inside the search field.
  final String hintText;

  /// Whether search is currently active.
  final ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);

  /// Callback fired whenever the text changes.
  final TextFieldChangeCallback? onChanged;

  /// Controller of the search text field.
  TextEditingController? controller;

  /// Whether the clear button is active (colored) or inactive (disabled).
  bool _clearActive = false;

  /// The last built default AppBar (kept for colors if needed).
  AppBar? _defaultAppBar;

  /// Optional TabBar to attach to the AppBar.
  TabBar? tabBar;

  /// Initializes the search bar.
  void beginSearch(BuildContext context) {
    ModalRoute.of(context)?.addLocalHistoryEntry(
      LocalHistoryEntry(
        onRemove: () {
          setState(() {
            isSearching.value = false;
          });
        },
      ),
    );

    setState(() {
      isSearching.value = true;
    });
  }

  /// Builds and stores the default app bar.
  AppBar? buildAppBar(BuildContext context) {
    _defaultAppBar = buildDefaultAppBar(context);
    return _defaultAppBar;
  }

  /// Builds the search bar AppBar using TaapdeelTextField.
  AppBar buildSearchBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AppBar(
      titleSpacing: 0,
      leading: IconButton(
        icon: const BackButtonIcon(),
        color: PsColors.backArrowColor,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () {
          controller?.clear();
          Navigator.pop(context);
          onClosed?.call();
        },
      ),
      backgroundColor: inBar ? null : theme.canvasColor,
      bottom: tabBar,
      title: Container(
        margin: const EdgeInsets.only(right: PsDimens.space16),
        child: TaapdeelTextField(
          controller: controller,
          keyboardType: TextInputType.text,
          hint: hintText,
          isSearchField: true,
          prefixIcon: Icons.search,
          suffixIcon: showClearButton
              ? IconButton(
            icon: const Icon(Icons.clear),
            color: _clearActive
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.35),
            onPressed: !_clearActive
                ? null
                : () {
              onCleared?.call();
              controller?.clear();
            },
          )
              : null,
          onChanged: onChanged,
          onSubmitted: (String val) async {
            if (closeOnSubmit) {
              await Navigator.maybePop(context);
            }
            if (clearOnSubmit) {
              controller?.clear();
            }
            onSubmitted?.call(val);
          },
        ),
      ),
    );
  }

  /// Returns an IconButton suitable for the default AppBar actions.
  IconButton getSearchAction(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        beginSearch(context);
      },
    );
  }

  /// Returns either the default AppBar or the search AppBar.
  AppBar? build(BuildContext context) {
    return isSearching.value ? buildSearchBar(context) : buildAppBar(context);
  }
}
