import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';

class DashboardSheets {
  static void openLocationBottomSheet({
    required BuildContext context,
    required VoidCallback onChangeTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LocationBottomSheet(
        onChangeTap: () {
          Navigator.pop(ctx);
          onChangeTap();
        },
      ),
    );
  }

  static void showAddBottomSheet({
    required BuildContext context,
    required VoidCallback onAddProduct,
    required VoidCallback onAddBulkProducts,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (BuildContext ctx) {
        return _AddItemBottomSheet(
          onAddProduct: () {
            Navigator.pop(ctx);
            onAddProduct();
          },
          onAddBulkProducts: () {
            Navigator.pop(ctx);
            onAddBulkProducts();
          },
        );
      },
    );
  }
}

class LowerDockedFabLocation extends FloatingActionButtonLocation {
  const LowerDockedFabLocation(this.offsetY);
  final double offsetY;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final Offset base =
    FloatingActionButtonLocation.centerDocked.getOffset(geometry);
    return Offset(base.dx, base.dy + offsetY);
  }
}

class _LocationBottomSheet extends StatelessWidget {
  const _LocationBottomSheet({
    Key? key,
    required this.onChangeTap,
  }) : super(key: key);

  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    final String locName = PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__LOCATION_NAME) ??
        '';
    final String townName = PsSharedPreferences.instance.shared
        .getString(PsConst.VALUE_HOLDER__LOCATION_TOWNSHIP_NAME) ??
        '';

    final String full =
    townName.trim().isEmpty ? locName : '$locName • $townName';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Icon(
                  Icons.my_location_rounded,
                  color: Colors.black.withOpacity(0.75),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'الموقع الحالي',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        full.isEmpty ? 'غير محدد' : full,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withOpacity(0.70),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: onChangeTap,
                icon: const Icon(Icons.edit_location_alt_rounded),
                label: const Text(
                  'تغيير الموقع',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إغلاق',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItemBottomSheet extends StatelessWidget {
  const _AddItemBottomSheet({
    Key? key,
    required this.onAddProduct,
    required this.onAddBulkProducts,
  }) : super(key: key);

  final VoidCallback onAddProduct;
  final VoidCallback onAddBulkProducts;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TaapdeelGlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'ابدأ رحلتك في التبديل',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'اختَر الطريقة الأنسب لك، ونحن نكمّل الباقي.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black.withOpacity(0.65),
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeroAddCard(
                  title: 'منتج للتبديل',
                  subtitle: 'أضف منتج واحد وسيقوم تبديل بترشيح أفضل فرص التبديل.',
                  icon: Icons.shopping_bag_rounded,
                  iconBackground: const Color(0xFFE6F5FF),
                  iconColor: const Color(0xFF1E40AF),
                  cardGradientStart: const Color(0xFFD4ECFF),
                  cardGradientEnd: const Color(0xFFD4ECFF),
                  onTap: onAddProduct,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroAddCard(
                  title: 'مجموعة منتجات',
                  subtitle: 'صوّر مجموعة منتجات مرة واحدة، وتبديل يجهز كل منتج لوحده.',
                  icon: Icons.grid_view_rounded,
                  iconBackground: const Color(0xFFD1F5EB),
                  iconColor: const Color(0xFF0F766E),
                  cardGradientStart: const Color(0xFFEFFFFF),
                  cardGradientEnd: const Color(0xFFD1F5EB),
                  onTap: onAddBulkProducts,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: PsColors.primary500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAddCard extends StatelessWidget {
  const _HeroAddCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final Color cardGradientStart;
  final Color cardGradientEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 132),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  cardGradientStart.withOpacity(0.70),
                  cardGradientEnd.withOpacity(0.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.9),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBackground.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.95),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 35),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.black.withOpacity(0.70),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}