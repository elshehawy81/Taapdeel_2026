import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

class TaapdeelAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TaapdeelAppBar({
    Key? key,
    this.title,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  final String? title;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Brand Blue موحّد
    final Color brandBlue = PsColors.primary500;

    // خلفية الـ AppBar الزجاجية (Ice Blue / Mint)
    final Color bg = backgroundColor ?? const Color(0xFFE0F1FF);

    final bool canPop = Navigator.of(context).canPop();

    // Elevation هنا بس للـ shadow (مش Elevation فعلي للـ AppBar)
    final double usedElevation = elevation ?? 10;

    return AppBar(
      backgroundColor: Colors.transparent, // مهم عشان glass يظهر
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      toolbarHeight: 35,
      leadingWidth: showBackButton ? 50 : 0,
      leading: showBackButton && canPop
          ? Padding(
        padding: const EdgeInsetsDirectional.only(
          start: PsDimens.space8,
        ),
        child: _GlassBackButton(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          brandBlue: brandBlue,
        ),
      )
          : null,
      title: title != null
          ? Text(
        title!,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: 0.1,
        ),
      )
          : null,
      actions: actions,
      shape: const Border(
        bottom: BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
      ),
      flexibleSpace: _GlassAppBarBackground(
        bgColor: bg,
        elevation: usedElevation,
        brandBlue: brandBlue,
      ),
    );
  }
}

/// خلفية الـ AppBar: Glassmorphism + Cut-Corner + Blue Shadow
class _GlassAppBarBackground extends StatelessWidget {
  const _GlassAppBarBackground({
    required this.bgColor,
    required this.elevation,
    required this.brandBlue,
  });

  final Color bgColor;
  final double elevation;
  final Color brandBlue;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(10), // شبه cut-corner
    );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xF5FFFFFF), // white @ ~96%
                Color(0xE0F1FF),   // ice blue
              ],
            ),
            border: const Border(
              bottom: BorderSide(
                color: Color(0xD6FFFFFF), // white @ ~84%
                width: 0.9,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: brandBlue.withValues(alpha: 0.14),
                blurRadius: elevation + 8,
                offset: Offset(0, elevation / 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر الرجوع: Capsule زجاجية صغيرة Premium
class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({
    required this.onTap,
    required this.brandBlue,
  });

  final VoidCallback onTap;
  final Color brandBlue;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xF2FFFFFF), // white @ ~95%
                    Color(0xE0F1FF),   // ice blue glass
                  ],
                ),
                border: Border.all(
                  color: Color(0xF2FFFFFF),
                  width: 0.9,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: brandBlue.withValues(alpha: 0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: brandBlue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
