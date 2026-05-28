import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../constant/ps_dimens.dart';

class TaapdeelButton extends StatefulWidget {
  const TaapdeelButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isExpanded = true,
    this.icon,
    this.outlined = false,
    this.backgroundColorOverride,
    this.foregroundColorOverride,
    this.width,
    this.textAlign = TextAlign.center,
    this.height = 52,

    /// Outer frame
    this.outerBorderColor = const Color(0xFF0FA3A6),
    this.outerBorderWidth = 2.2,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isExpanded;
  final Widget? icon;
  final bool outlined;
  final Color? backgroundColorOverride;
  final Color? foregroundColorOverride;
  final double? width;
  final TextAlign textAlign;
  final double height;

  final Color outerBorderColor;
  final double outerBorderWidth;

  @override
  State<TaapdeelButton> createState() => _TaapdeelButtonState();
}

class _TaapdeelButtonState extends State<TaapdeelButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool enabled = widget.onPressed != null;

    // ==========================
    // Taapdeel Logo Palette
    // ==========================
    const Color navy1 = Color(0xFF0C2345); // Deep navy
    const Color navy2 = Color(0xFF102E5C); // Slightly brighter navy
    const Color teal1 = Color(0xFF0FA3A6); // Teal
    const Color teal2 = Color(0xFF1CC7B8); // Brighter teal
    const Color cyanGlow = Color(0xFF64F3FF); // light cyan glow

    final bool isFilledPrimary = widget.isPrimary && !widget.outlined;
    final bool isOutlinedStyle = widget.outlined || !isFilledPrimary;

    // Text color
    final Color textColor = widget.foregroundColorOverride ??
        (isFilledPrimary ? Colors.white : (widget.isPrimary ? navy2 : const Color(0xFF333333)));

    final double screenW = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenW <= 360;
    final bool isOutlinedStyleSmall = isSmallScreen && isOutlinedStyle;

    final double effectiveFontSize = isOutlinedStyleSmall ? 14.5 : 16.5;
    final double effectiveLetterSpacing = isOutlinedStyleSmall ? 0.0 : 0.15;

    final TextStyle textStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: effectiveFontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: effectiveLetterSpacing,
      color: enabled ? textColor : textColor.withValues(alpha: 0.40),
    ) ??
        TextStyle(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: effectiveLetterSpacing,
          color: enabled ? textColor : textColor.withValues(alpha: 0.40),
        );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          IconTheme(
            data: IconThemeData(size: isOutlinedStyleSmall ? 16 : 18),
            child: widget.icon!,
          ),
          SizedBox(width: isOutlinedStyleSmall ? 6 : PsDimens.sm),
        ],
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.label,
              textAlign: widget.textAlign,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: textStyle,
            ),
          ),
        ),
      ],
    );

    // Base color for shadows (fallback)
    final Color baseColor =
        widget.backgroundColorOverride ?? (widget.isPrimary ? teal1 : colorScheme.secondary);

    // ==========================
    // FILL GRADIENTS (Logo-like)
    // ==========================
    final Gradient fillGradient = widget.backgroundColorOverride != null
        ? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        widget.backgroundColorOverride!,
        widget.backgroundColorOverride!,
      ],
    )
        : isFilledPrimary
    // Primary: Navy -> Teal (like logo)
        ? const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: <double>[0.0, 0.45, 1.0],
      colors: <Color>[
        navy1,
        navy2,
        teal1,
      ],
    )
    // Secondary/Outlined: glassy white with tiny teal tint
        : const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xF9FFFFFF),
        Color(0xEEF7FF),
      ],
    );

    // Inner border
    final Color borderColor = isFilledPrimary
        ? const Color(0x14FFFFFF) // subtle white edge
        : teal1.withValues(alpha: 0.22);

    // Shadows
    final double shadowBlur = !enabled
        ? 0
        : isFilledPrimary
        ? (_isPressed ? 10 : 16)
        : (_isPressed ? 8 : 12);

    final double shadowOffsetY = !enabled
        ? 0
        : isFilledPrimary
        ? (_isPressed ? 3 : 7)
        : (_isPressed ? 2 : 4);

    // ==========================
    // BUTTON CORE
    // ==========================
    Widget buttonCore = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      height: widget.height,
      padding: EdgeInsets.symmetric(
        horizontal: isOutlinedStyleSmall ? 12 : PsDimens.lg,
        vertical: PsDimens.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: fillGradient,
        border: Border.all(
          color: borderColor,
          width: isFilledPrimary ? 0.9 : 1.0,
        ),
        boxShadow: <BoxShadow>[
          if (enabled)
          // main depth shadow (navy/teal mix)
            BoxShadow(
              color: (isFilledPrimary ? navy1 : baseColor).withValues(
                alpha: isFilledPrimary ? 0.35 : 0.16,
              ),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowOffsetY),
            ),

          if (enabled && isFilledPrimary)
          // subtle teal glow like logo's core
            BoxShadow(
              color: teal2.withValues(alpha: _isPressed ? 0.16 : 0.22),
              blurRadius: _isPressed ? 14 : 20,
              offset: const Offset(0, 6),
              spreadRadius: 0.5,
            ),
        ],
      ),
      child: Center(child: content),
    );

    // ==========================
    // OUTER FRAME (Logo-like)
    // ==========================
    final Color effectiveOuterBorderColor = isOutlinedStyle
        ? teal1.withValues(alpha: 0.50) // outlined: teal frame
        : widget.outerBorderColor.withValues(alpha: 0.92);

    final double effectiveOuterBorderWidth =
    isOutlinedStyle ? widget.outerBorderWidth + 0.2 : widget.outerBorderWidth;

    // Outer glow ring (optional but gives the "logo aura")
    final List<BoxShadow> outerGlow = <BoxShadow>[
      if (enabled && isFilledPrimary)
        BoxShadow(
          color: cyanGlow.withValues(alpha: _isPressed ? 0.10 : 0.14),
          blurRadius: _isPressed ? 18 : 26,
          spreadRadius: _isPressed ? 0.4 : 0.8,
          offset: const Offset(0, 0),
        ),
    ];

    Widget framed = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: effectiveOuterBorderColor,
          width: effectiveOuterBorderWidth,
        ),
        boxShadow: outerGlow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? widget.onPressed : null,
            splashColor: teal2.withValues(alpha: 0.16),
            highlightColor: Colors.white.withValues(alpha: 0.10),
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            //borderRadius: borderRadius, // لو عندك
            child: DecoratedBox(
              decoration: BoxDecoration(
                //borderRadius: borderRadius,
                color: Colors.white.withOpacity(isOutlinedStyle ? 0.10 : 0.22),
                border: Border.all(
                  color: Colors.white.withOpacity(isOutlinedStyle ? 0.38 : 0.28),
                  width: isOutlinedStyle ? 1.4 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: buttonCore,
            ),
          ),
        ),
      ),
    );

    if (widget.width != null) {
      framed = SizedBox(width: widget.width, child: framed);
    } else if (widget.isExpanded) {
      framed = SizedBox(width: double.infinity, child: framed);
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      opacity: enabled ? 1.0 : 0.55,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        scale: _isPressed ? 0.97 : 1.0,
        child: framed,
      ),
    );
  }
}