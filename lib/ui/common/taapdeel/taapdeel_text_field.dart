import 'dart:ui'; // للـ blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constant/ps_dimens.dart';

/// TaapdeelTextField – Premium Glass + Mint / Ice Blue
///
/// نفس الـ API القديم بالكامل:
/// - label / hint / helperText
/// - prefixIcon / suffixIcon
/// - isSearchField لعمل Search Bar بشكل مختلف
class TaapdeelTextField extends StatefulWidget {
  const TaapdeelTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,         // ← NEW
    this.errorText,
    this.isSearchField = false,
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String? label;
  final String? hint;
  final String? helperText;

  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final bool obscureText;
  final bool enabled;
  final bool readOnly;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final int maxLines;
  final int? minLines;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;   // ← NEW


  /// مود خاص للـ Search Bar (pill أطول وshadow أكبر)
  final bool isSearchField;

  @override
  State<TaapdeelTextField> createState() => _TaapdeelTextFieldState();
}

class _TaapdeelTextFieldState extends State<TaapdeelTextField> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant TaapdeelTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
      _focusNode.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final bool enabled = widget.enabled;

    // Brand blue الأساسي (لـ focus + shadow)
    const Color baseColor = Color(0xFF3167B0);

    // Radius أكبر للـ search bar
    final BorderRadius radius = widget.isSearchField
        ? BorderRadius.circular(26)
        : const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(8), // شبه cut-corner
    );

    // حدود خفيفة جدًا (هتتعدل Animated عند الـ focus)
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(
        color: Color(0x33FFFFFF), // white @ 20%
        width: 1.0,
      ),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: baseColor.withValues(alpha: 0.75),
        width: 1.6,
      ),
    );

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 1.6,
      ),
    );

    // ارتفاع مختلف للـ Search bar
    final double verticalPadding =
    widget.isSearchField ? PsDimens.sm : PsDimens.sm + 4;

    // ==========================
    // TextField نفسه
    // ==========================
    final TextField textField = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      enabled: enabled,
      readOnly: widget.readOnly,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.obscureText ? 1 : widget.minLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      cursorColor: baseColor,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        isDense: widget.isSearchField,
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,

        // icon alignment + color animation
        prefixIcon: widget.prefixIcon != null
            ? Padding(
          padding: const EdgeInsets.only(top: 2), // +2px لأعلى
          child: Icon(widget.prefixIcon),
        )
            : null,
        suffixIcon: widget.suffixIcon,
        prefixIconColor: _isFocused
            ? baseColor
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
        suffixIconColor: _isFocused
            ? baseColor
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.75),

        filled: false, // الخلفية من الـ Container الخارجي
        contentPadding: EdgeInsets.symmetric(
          horizontal: PsDimens.lg,
          vertical: verticalPadding,
        ),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        disabledBorder: baseBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,

        // label / hint styles (اللون هيتحوّل تلقائي مع الـ focus)
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: _isFocused
              ? baseColor.withValues(alpha: 0.90)
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.80),
        ),
        floatingLabelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: _isFocused
              ? baseColor.withValues(alpha: 0.95)
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.80),
        ),
        helperStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );

    // ==========================
    // Animated Glass + Border + Shadow
    // ==========================

    // شادو ديناميكي مع الـ focus + search mode
    final double shadowBlur = !enabled
        ? 0
        : widget.isSearchField
        ? (_isFocused ? 20 : 12)
        : (_isFocused ? 14 : 8);

    final double shadowOffsetY = !enabled
        ? 0
        : widget.isSearchField
        ? (_isFocused ? 8 : 5)
        : (_isFocused ? 6 : 3);

    // Border خارجي أقوى شوية مع focus
    final Color outerBorderColor = _isFocused
        ? Colors.white.withValues(alpha: 0.95)
        : const Color(0xE6FFFFFF); // white @ 90%

    final double outerBorderWidth = _isFocused ? 1.3 : 1.0;

    // Gradient داخلي (White → Mint) مع تركيز بسيط عند الـ focus
    final List<Color> innerGradientColors = _isFocused
        ? const <Color>[
      Color(0xF9FFFFFF), // أبيض أوضح
      Color(0xF5FFFFFF), // Mint أفتح
    ]
        : const <Color>[
      Color(0xF5FFFFFF),
      Color(0xF9FFFFFF),
    ];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      opacity: enabled ? 1.0 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: enabled
              ? <BoxShadow>[
            BoxShadow(
              color: baseColor.withValues(
                alpha: _isFocused ? 0.22 : 0.12,
              ),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowOffsetY),
            ),
          ]
              : const <BoxShadow>[],
          border: Border.all(
            color: outerBorderColor,
            width: outerBorderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.isSearchField ? 18 : 14,
              sigmaY: widget.isSearchField ? 18 : 14,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: innerGradientColors,
                ),
              ),
              child: textField,
            ),
          ),
        ),
      ),
    );
  }
}
