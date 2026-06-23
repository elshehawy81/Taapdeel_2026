import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

class TaapdeelChip extends StatelessWidget {
  const TaapdeelChip({
    Key? key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.compact = false,
    this.minWidth = 0,
    this.withShadow = true,
    this.height, // ✅ NEW
    this.showCheck = false, // ✅ NEW (خليها false للـ premium look)
  }) : super(key: key);

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final double minWidth;
  final bool compact;
  final bool withShadow;
  final double? height;
  final bool showCheck;

  static const Color brandBlue = Color(0xFF3167B0);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool enabled = onTap != null;

    final BorderRadius radius = BorderRadius.circular(compact ? 14 : 18);

    final double h = height ?? (compact ? 36 : 44);

    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: compact ? PsDimens.space10 : PsDimens.space14,
      vertical: 0,
    );

    final TextStyle labelStyle = theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: compact ? 12.5 : 13.5,
      height: 1.0,
      color: selected ? Colors.white : const Color(0xFF16355B),
      letterSpacing: 0.1,
    );

    // ✅ Background gradients (more premium / less flat)
    final List<Color> bg = selected
        ? const <Color>[
      Color(0xFF3A73C4),
      Color(0xFF2C5EA3),
    ]
        : const <Color>[
      Color(0xFFF1F7FF), // بدل F8FFFFFF (كان فاتح جدًا)
      Color(0xFFD9ECFF), // أغمق سنة علشان يبان على الخلفية
    ];


    // ✅ Borders (outer + inner highlight)
    final Color outerBorder = selected
        ? Colors.white.withOpacity(0.55)
        : const Color(0xFFB8D9FF); // أغمق من D7E9FF

    final Color innerHighlight = selected
        ? Colors.white.withOpacity(0.22)
        : Colors.white.withOpacity(0.85);


    // ✅ Shadows (cleaner)
    final List<BoxShadow> shadows = (!withShadow || !enabled)
        ? const <BoxShadow>[]
        : selected
        ? <BoxShadow>[
      BoxShadow(
        color: brandBlue.withOpacity(0.26),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 22,
        offset: const Offset(0, 14),
      ),
    ]
        : <BoxShadow>[
      BoxShadow(
        color: Colors.black.withOpacity(0.10), // ✅ كان 0.06
        blurRadius: 18,                         // ✅ كان 14
        offset: const Offset(0, 10),            // ✅ كان 8
      ),
    ];

    final double blurSigma = selected ? 18 : 14;

    Widget core = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(minWidth: minWidth),
      height: h,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bg,
        ),
        border: Border.all(color: outerBorder, width: 1.0),
        boxShadow: shadows,
      ),
      child: Stack(
        children: <Widget>[

          // ✅ Sheen (top glossy highlight)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: selected ? 0.00 : 0.10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    color: const Color(0xFF3167B0), // brand tint
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFFFFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: <double>[0.0, 0.55],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ✅ Content
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: compact ? 15 : 16,
                    color: selected ? Colors.white : const Color(0xFF0F2B55),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
                if (selected && showCheck) ...<Widget>[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // ✅ Glass blur
    core = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: core,
      ),
    );

    if (!enabled) {
      core = Opacity(opacity: 0.60, child: core);
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.10),
        highlightColor: Colors.white.withOpacity(0.06),
        child: core,
      ),
    );
  }
}
