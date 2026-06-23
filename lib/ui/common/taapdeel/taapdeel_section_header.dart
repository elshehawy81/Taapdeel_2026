import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

/// TaapdeelSectionHeader
///
/// هيدر موحّد لأقسام الشاشات (قوائم، كروت، سلايدر...).
class TaapdeelSectionHeader extends StatelessWidget {
  const TaapdeelSectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.leadingIcon,
    this.padding =
    const EdgeInsets.symmetric(vertical: PsDimens.space5),
  }) : super(key: key);

  final String title;
  final String? subtitle;

  final String? actionLabel;
  final VoidCallback? onActionTap;

  final IconData? leadingIcon;

  final EdgeInsetsGeometry padding;

  bool get _hasAction =>
      actionLabel != null &&
          actionLabel!.isNotEmpty &&
          onActionTap != null;

  bool get _hasSubtitle => subtitle != null && subtitle!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final Color accentColor = colorScheme.primary;
    final TextStyle titleStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
      letterSpacing: 0.1,
    );

    final TextStyle subtitleStyle = theme.textTheme.bodySmall!.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // ===== Left: Title + Subtitle مع Capsule صغيرة =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _TitleWithAccent(
                  title: title,
                  style: titleStyle,
                  accentColor: accentColor,
                  leadingIcon: leadingIcon,
                ),
                if (_hasSubtitle) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: subtitleStyle,
                  ),
                ],
              ],
            ),
          ),

          // ===== Right: Action Button (اختياري) =====
          if (_hasAction) ...<Widget>[
            const SizedBox(width: PsDimens.space8),
            _SectionActionButton(
              label: actionLabel!,
              onTap: onActionTap!,
              accentColor: accentColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _TitleWithAccent extends StatelessWidget {
  const _TitleWithAccent({
    required this.title,
    required this.style,
    required this.accentColor,
    this.leadingIcon,
  });

  final String title;
  final TextStyle style;
  final Color accentColor;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(999));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PsDimens.space12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color(0xD9FFFFFF), // white @ ~85%
                Color(0xCCE0F1FF), // ice blue glass
              ],
            ),
            border: Border.all(
              color: const Color(0xF2FFFFFF), // white @ ~95%
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[
                        accentColor.withValues(alpha: 0.95),
                        accentColor.withValues(alpha: 0.70),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    leadingIcon,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر Action على اليمين: "عرض الكل" مثلاً
class _SectionActionButton extends StatelessWidget {
  const _SectionActionButton({
    required this.label,
    required this.onTap,
    required this.accentColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                    Color(0xF5FFFFFF), // white @ ~96%
                    Color(0xE0F1FF),   // ice blue glass
                  ],
                ),
                border: Border.all(
                  color: const Color(0xF2FFFFFF),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: accentColor,
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
