import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taapdeel/ui/Contacts/contact_network_provider.dart';
import '../content/intro_slide3_content.dart';
import '../logic/persona_resolver.dart';
import '../models/intro_models.dart';

/// Slide 3 — Redesigned: Trust network (family & friends) + WhatsApp share CTA
class Slide3SmartAiReco extends StatefulWidget {
  const Slide3SmartAiReco({
    Key? key,
    required this.psValueHolder,
    required this.playKey,
  }) : super(key: key);

  final PsValueHolder? psValueHolder;
  final int playKey;

  @override
  State<Slide3SmartAiReco> createState() => _Slide3SmartAiRecoState();
}

class _Slide3SmartAiRecoState extends State<Slide3SmartAiReco>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant Slide3SmartAiReco oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playKey != widget.playKey) {
      _c.stop();
      _c.reset();
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _fade({
    required Widget child,
    required double begin,
    required double end,
    double dy = 12,
  }) {
    final anim = CurvedAnimation(
      parent: _c,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, (1 - anim.value) * dy),
          child: child,
        ),
      ),
    );
  }

  IntroSlide3TrustModel _resolveModel() {
    final IntroPersonaKey key =
    PersonaResolver.resolve(widget.psValueHolder, debugLogs: false);
    return slide3TrustContent[key] ??
        slide3TrustContent[IntroPersonaKey.female23Plus]!;
  }

  Future<void> _requestContactsPermission(BuildContext context) async {
    try {
      final ContactNetworkProvider provider =
      Provider.of<ContactNetworkProvider>(context, listen: false);
      final bool ok = await provider.requestPermissionAndSync(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            ok
                ? 'تمام، سنعرض لك الأصدقاء والأقارب الموجودين على تبديل.'
                : 'يمكنك تفعيل جهات الاتصال لاحقًا من زر الشبكة أعلى التطبيق.',
          ),
        ),
      );
    } catch (_) {
      final PermissionStatus status = await Permission.contacts.request();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            status.isGranted
                ? 'تم تفعيل صلاحية جهات الاتصال.'
                : 'يمكنك تفعيل جهات الاتصال لاحقًا من زر الشبكة أعلى التطبيق.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = _resolveModel();

    final Size s = MediaQuery.of(context).size;
    final double h = s.height;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final bool compact = h < 760 || s.width < 380;
    final double reserved = 160 + bottomInset;

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(bottom: reserved),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: compact ? 10 : 16),

            // ── Logo ─────────────────────────────────────────────────
            _fade(
              begin: 0.00,
              end: 0.10,
              child: _Logo(),
            ),
            SizedBox(height: compact ? 8 : 12),

            // ── Header ───────────────────────────────────────────────
            _fade(
              begin: 0.05,
              end: 0.18,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      model.headerTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1A3F6F),
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 20 : 22,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 8),
                    Text(
                      model.headerSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF5A6A7A),
                        fontSize: compact ? 13 : 14.5,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: compact ? 16 : 22),

            // ── Trust Constellation ──────────────────────────────────
            _fade(
              begin: 0.18,
              end: 0.48,
              child: SizedBox(
                height: compact ? 190 : 220,
                child: _TrustConstellation(
                  model: model,
                  controller: _c,
                  membersInterval: const Interval(0.22, 0.48),
                  compact: compact,
                ),
              ),
            ),

            SizedBox(height: compact ? 14 : 18),

            // ── Trust Badge ──────────────────────────────────────────

           /* _fade(
              begin: 0.48,
              end: 0.64,
              dy: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _ContactsPermissionCTA(
                  compact: compact,
                  onTap: () => _requestContactsPermission(context),
                ),
              ),
            ),*/


            SizedBox(height: compact ? 14 : 18),

            // ── Network Products ─────────────────────────────────────
            _fade(
              begin: 0.66,
              end: 0.82,
              dy: 10,
              child: Column(
                children: [
                  Text(
                    'ترشيحات من اقاربك واصحابك',
                    style: TextStyle(
                      color: const Color(0xFF1A3F6F),
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 15 : 17,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _NetworkProductsRow(
                      products: model.networkProducts,
                      compact: compact,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: compact ? 10 : 14),
            _fade(
              begin: 0.82,
              end: 0.96,
              dy: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _TrustBadge(model: model, compact: compact),
              ),
            ),


            SizedBox(height: compact ? 14 : 18),

          ],
        ),
      ),
    );
  }
}

class _ContactsPermissionCTA extends StatelessWidget {
  const _ContactsPermissionCTA({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.86),
        border: Border.all(color: const Color(0xFF63CAD6).withOpacity(0.32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB8F4FF), Color(0xFF0A7EA0)],
                  ),
                ),
                child: const Icon(Icons.groups_2_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'استكشف منتجات أقاربك وأصحابك',
                      style: TextStyle(
                        color: const Color(0xFF1A3F6F),
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 13.5 : 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'نستخدم جهات الاتصال فقط لعرض اصحابك واقاربك على التطبيق.',
                      style: TextStyle(
                        color: const Color(0xFF5A6A7A),
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 11.2 : 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFF63CAD6), Color(0xFF007D98)],
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'كون دائرة التبديل الخاصة بك',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TryPulseChip(compact: compact),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TryPulseChip extends StatefulWidget {
  const _TryPulseChip({required this.compact});

  final bool compact;

  @override
  State<_TryPulseChip> createState() => _TryPulseChipState();
}

class _TryPulseChipState extends State<_TryPulseChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<Color?> _bg;
  late final Animation<Color?> _fg;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat(reverse: true);

    final CurvedAnimation curve = CurvedAnimation(
      parent: _pulse,
      curve: Curves.easeInOutCubic,
    );

    _scale = Tween<double>(begin: 1.0, end: 1.10).animate(curve);
    _bg = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFFFF3C4),
    ).animate(curve);
    _fg = ColorTween(
      begin: const Color(0xFF007D98),
      end: const Color(0xFF6B3D00),
    ).animate(curve);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          final Color bg = _bg.value ?? Colors.white;
          final Color fg = _fg.value ?? const Color(0xFF007D98);

          return Container(
            padding: EdgeInsetsDirectional.only(
              start: widget.compact ? 8 : 9,
              end: widget.compact ? 6 : 7,
              top: widget.compact ? 4 : 5,
              bottom: widget.compact ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFFFB020).withOpacity(0.30 + (_pulse.value * 0.18)),
                  blurRadius: 9 + (_pulse.value * 5),
                  spreadRadius: _pulse.value * 1.1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'إذن جهات الاتصال',
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w900,
                    fontSize: widget.compact ? 11 : 11.5,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.translate(
                  offset: Offset(2.0 * _pulse.value, 0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: fg,
                    size: widget.compact ? 13 : 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// ── Logo ───────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Taapdeel_logo.png',
      height: 52,
      errorBuilder: (_, __, ___) => const Text(
        'TaapdeeL',
        style: TextStyle(
          color: Color(0xFF1A3F6F),
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}

// ── Trust Constellation ────────────────────────────────────────────────────────
class _TrustConstellation extends StatelessWidget {
  const _TrustConstellation({
    required this.model,
    required this.controller,
    required this.membersInterval,
    required this.compact,
  });

  final IntroSlide3TrustModel model;
  final AnimationController controller;
  final Interval membersInterval;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double centerSize = compact ? 50.0 : 84.0;
    final double memberSize = compact ? 54.0 : 62.0;
    final double orbitRadius = compact ? 72.0 : 84.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = CurvedAnimation(
          parent: controller,
          curve: membersInterval,
        ).value;

        return CustomPaint(
          painter: _ConstellationLinePainter(
            memberCount: model.members.length,
            orbitRadius: orbitRadius,
            progress: t,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center: "أنت"
              Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: _CenterAvatar(size: centerSize),
              ),
              // Members
              ...List.generate(model.members.length, (i) {
                final angle = (2 * math.pi / model.members.length) * i - math.pi / 2;
                final dx = math.cos(angle) * orbitRadius;
                final dy = math.sin(angle) * orbitRadius;

                final memberDelay = i / model.members.length;
                final memberT = ((t - memberDelay * 0.3) / 0.7).clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Opacity(
                    opacity: memberT,
                    child: Transform.scale(
                      scale: 0.7 + memberT * 0.3,
                      child: _MemberAvatar(
                        member: model.members[i],
                        size: memberSize,
                        compact: compact,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ConstellationLinePainter extends CustomPainter {
  _ConstellationLinePainter({
    required this.memberCount,
    required this.orbitRadius,
    required this.progress,
  });

  final int memberCount;
  final double orbitRadius;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF0FA3A6).withOpacity(0.3 * progress)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < memberCount; i++) {
      final angle = (2 * math.pi / memberCount) * i - math.pi / 2;
      final memberX = center.dx + math.cos(angle) * orbitRadius;
      final memberY = center.dy + math.sin(angle) * orbitRadius;

      canvas.drawLine(center, Offset(memberX, memberY), paint);

      // Small dot at member position
      final dotPaint = Paint()
        ..color = const Color(0xFF0FA3A6).withOpacity(0.6 * progress)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(memberX, memberY), 4 * progress, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ConstellationLinePainter old) => old.progress != progress;
}

class _CenterAvatar extends StatelessWidget {
  const _CenterAvatar({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEDF5FF),
            border: Border.all(
              color: const Color(0xFF0FA3A6),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0FA3A6).withOpacity(0.20),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF1A3F6F),
              size: 32,
            ),
          ),
        ),

      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
    required this.size,
    required this.compact,
  });
  final IntroTrustMemberModel member;
  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  member.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEDF5FF),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF1A3F6F),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0FA3A6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 11),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 4 : 5),
        Text(
          member.label,
          style: TextStyle(
            color: const Color(0xFF1A3F6F),
            fontWeight: FontWeight.w700,
            fontSize: compact ? 11 : 12,
          ),
        ),
      ],
    );
  }
}

// ── Trust Badge ────────────────────────────────────────────────────────────────
class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.model, required this.compact});
  final IntroSlide3TrustModel model;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  model.trustBadgeTitle,
                  style: TextStyle(
                    color: const Color(0xFF1A3F6F),
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 14 : 16,
                  ),
                ),
                SizedBox(height: compact ? 4 : 5),
                Text(
                  model.trustBadgeSubtitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: const Color(0xFF5A6A7A),
                    fontSize: compact ? 12 : 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 12 : 16),
          Container(
            width: compact ? 46 : 54,
            height: compact ? 46 : 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0FA3A6), Color(0xFF1A3F6F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: compact ? 26 : 30,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Network Products ───────────────────────────────────────────────────────────
// Replace only _NetworkProductsRow with this implementation.
// This prevents card overlap by calculating exact card widths and inserting real gaps,
// instead of relying on Expanded + directional Padding.

class _NetworkProductsRow extends StatelessWidget {
  const _NetworkProductsRow({required this.products, required this.compact});
  final List<IntroNetworkProductModel> products;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final List<IntroNetworkProductModel> visibleProducts = products.take(3).toList();
    final double gap = compact ? 8.0 : 10.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int count = visibleProducts.length;
          if (count == 0) return const SizedBox.shrink();

          final double totalGaps = gap * (count - 1);
          final double cardWidth = (constraints.maxWidth - totalGaps) / count;

          return Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(count, (int index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: cardWidth.clamp(76.0, 132.0),
                    child: _NetworkProductCard(
                      product: visibleProducts[index],
                      compact: compact,
                    ),
                  ),
                  if (index != count - 1) SizedBox(width: gap),
                ],
              );
            }),
          );
        },
      ),
    );
  }
}

// Also replace _NetworkProductCard with this safer version.
// Main changes:
// 1) clipBehavior prevents image/badge overflow outside card.
// 2) smaller aspect ratio for compact screens.
// 3) the top "from" badge has max width + ellipsis so it cannot cover the next card.

class _NetworkProductCard extends StatelessWidget {
  const _NetworkProductCard({required this.product, required this.compact});
  final IntroNetworkProductModel product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              AspectRatio(
                aspectRatio: compact ? 1.02 : 1.08,
                child: Image.asset(
                  product.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEDF5FF),
                    child: const Icon(
                      Icons.image_rounded,
                      color: Color(0xFF1A3F6F),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 5,
                end: 5,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: compact ? 58 : 68),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3F6F).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      product.fromLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 5 : 7,
              compact ? 5 : 7,
              compact ? 5 : 7,
              compact ? 6 : 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1A3F6F),
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 10 : 11,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: compact ? 4 : 5),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 7,
                    vertical: compact ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0FA3A6).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(99),
                  ),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
