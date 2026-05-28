import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';

/// TaapdeelCard
///
/// كارت موحّد بهوية Taapdeel:
/// - Soft Glassmorphism + Neo-Brutal Shadow
/// - Curved + شبه Cut-Corner أسفل اليمين
/// - يدعم onTap (Interactive) أو Static
/// - يدعم leading / title / subtitle / trailing / body / footer.
/// - يحتوي على:
///   • Entrance Animation: Fade + SlideUp
///   • Press Animation: Scale + Shadow change
class TaapdeelCard extends StatefulWidget {
  const TaapdeelCard({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.body,
    this.footer,
    this.onTap,
    this.padding = const EdgeInsets.all(PsDimens.space16),
    this.margin,
    this.accentColor,
    this.elevated = true,
    this.backgroundImage,
    this.enableEntranceAnimation = true,
    this.appearDuration = const Duration(milliseconds: 280),
    this.appearDelay = Duration.zero,
  }) : super(key: key);

  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? body;
  final Widget? footer;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;
  final bool elevated;
  final ImageProvider? backgroundImage;

  /// تفعيل / إلغاء أنيميشن الدخول
  final bool enableEntranceAnimation;

  /// مدة أنيميشن الدخول
  final Duration appearDuration;

  /// Delay اختياري (مفيد لو عايز تعمل Stagger من برّه)
  final Duration appearDelay;

  bool get _hasHeader => title != null || leading != null || trailing != null;

  @override
  State<TaapdeelCard> createState() => _TaapdeelCardState();
}

class _TaapdeelCardState extends State<TaapdeelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appearController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const Duration _pressDuration = Duration(milliseconds: 120);

  bool _isPressed = false;

  // Brand Blue الرسمي المستخدم في كل App
  static const Color _brandBlue = Color(0xFF3167B0);

  @override
  void initState() {
    super.initState();

    _appearController = AnimationController(
      vsync: this,
      duration: widget.appearDuration,
    );

    _fadeAnim = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06), // حوالي 8–12px حسب الارتفاع
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.enableEntranceAnimation) {
      if (widget.appearDelay == Duration.zero) {
        _appearController.forward();
      } else {
        Future<void>.delayed(widget.appearDelay, () {
          if (mounted) {
            _appearController.forward();
          }
        });
      }
    } else {
      _appearController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (widget.onTap == null) return;
    if (_isPressed == pressed) return;
    setState(() {
      _isPressed = pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.accentColor ?? _brandBlue;

    final BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(12), // شبه cut-corner
    );

    // Shadows في الوضع العادي + عند الضغط
    final List<BoxShadow> normalShadows = widget.elevated
        ? <BoxShadow>[
      BoxShadow(
        color: accent.withValues(alpha: 0.22),
        blurRadius: 24,
        offset: const Offset(0, 14),
      ),
    ]
        : <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    final List<BoxShadow> pressedShadows = widget.elevated
        ? <BoxShadow>[
      BoxShadow(
        color: accent.withValues(alpha: 0.18),
        blurRadius: 16,
        offset: const Offset(0, 9),
      ),
    ]
        : <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];

    final List<BoxShadow> currentShadows =
    _isPressed ? pressedShadows : normalShadows;

    // ===== محتوى الكارت =====
    Widget cardContent = Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget._hasHeader) ...<Widget>[
            _CardHeader(
              leading: widget.leading,
              title: widget.title,
              subtitle: widget.subtitle,
              trailing: widget.trailing,
              accent: accent,
            ),
            if (widget.body != null) const SizedBox(height: PsDimens.space12),
          ],
          if (!widget._hasHeader && widget.body != null) ...<Widget>[
            widget.body!,
          ] else if (widget.body != null) ...<Widget>[
            widget.body!,
          ],
          if (widget.footer != null) ...<Widget>[
            const SizedBox(height: PsDimens.space12),
            widget.footer!,
          ],
        ],
      ),
    );

    // خلفية صورة خفيفة جدًا (Overlay ناعم)
    if (widget.backgroundImage != null) {
      cardContent = Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: radius,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withValues(alpha: 0.60),
                  BlendMode.srcATop,
                ),
                child: Image(
                  image: widget.backgroundImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          cardContent,
        ],
      );
    }

    // ===== طبقة الزجاج + AnimatedContainer للـ shadow =====
    Widget glassCore = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: currentShadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xDBFFFFFF), // white @ ~86%
                  Color(0x85E0F1FF), // Ice Blue @ ~52%
                ],
              ),
              // وضوح أعلى 5% تقريبًا عن السابق
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.97),
                width: 1.0,
              ),
            ),
            child: cardContent,
          ),
        ),
      ),
    );

    // Press animation (Scale) + InkWell لو onTap موجود
    if (widget.onTap != null) {
      glassCore = AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: _pressDuration,
        curve: Curves.easeOutCubic,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: glassCore,
          ),
        ),
      );
    }

    Widget result = glassCore;

    // Entrance Animation (Fade + SlideUp)
    result = FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: result,
      ),
    );

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: PsDimens.space12),
      child: result,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.accent,
  });

  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Color accent;

  bool get _hasSubtitle => subtitle != null && subtitle!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final TextStyle titleStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
      letterSpacing: 0.1,
    );

    final TextStyle subtitleStyle = theme.textTheme.bodySmall!.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Row(
      crossAxisAlignment:
      _hasSubtitle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          _LeadingWrapper(
            child: leading!,
            accent: accent,
          ),
          const SizedBox(width: PsDimens.space12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title != null) ...<Widget>[
                Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ],
              if (_hasSubtitle) ...<Widget>[
                const SizedBox(height: 2),
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
        if (trailing != null) ...<Widget>[
          const SizedBox(width: PsDimens.space8),
          trailing!,
        ],
      ],
    );
  }
}

class _LeadingWrapper extends StatelessWidget {
  const _LeadingWrapper({
    required this.child,
    required this.accent,
  });

  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.96),
            accent.withValues(alpha: 0.78),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.40),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
        child: child,
      ),
    );
  }
}
