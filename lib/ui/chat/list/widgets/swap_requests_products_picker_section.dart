import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/ui/chat/list/swap_request_grouping_helper.dart';
import 'package:taapdeel/viewobject/product.dart';

import '../../enum/user_type.dart';

class SwapRequestsProductsPickerSection extends StatelessWidget {
  const SwapRequestsProductsPickerSection({
    Key? key,
    required this.groups,
    required this.userType,
    required this.selectedGroupKey,
    required this.onSelected,
    this.title,
    this.emptyText = 'لا توجد منتجات عليها طلبات حالياً',
  }) : super(key: key);

  final List<GroupedSwapRequests> groups;
  final UserType userType;
  final String? selectedGroupKey;
  final ValueChanged<GroupedSwapRequests> onSelected;
  final String? title;
  final String emptyText;

  static const Color _kPrimary = Color(0xFF0C587A);
  static const Color _kPrimaryDark = Color(0xFF011934);
  static const Color _kAccent = Color(0xFF24A9C4);
  static const Color _kSoftBg = Color(0xFFF4FAFC);
  static const Color _kBorder = Color(0xFFD8EDF3);
  static const Color _kMuted = Color(0xFF607684);
  static const Color _kWarningBg = Color(0xFFFFF6E8);
  static const Color _kWarningText = Color(0xFFB26A00);

  ImageProvider _imageProviderFor(Product p) {
    final String? raw = p.defaultPhoto?.imgPath;

    if (raw == null || raw.trim().isEmpty) {
      return const AssetImage('assets/images/img_placeholder.png');
    }

    final String path = raw.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    return NetworkImage('${PsConfig.ps_app_image_url}$path');
  }

  String _productTitle(Product p) {
    final String title = (p.title ?? '').trim();
    if (title.isNotEmpty) return title;
    return 'منتج بدون اسم';
  }

  String _headerTitle() {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }

    return userType == UserType.seller
        ? 'اختر منتجك لمراجعة العروض عليه'
        : 'اختر المنتج الذي أرسلت به طلبات';
  }

  int _totalRequestsCount(List<GroupedSwapRequests> list) {
    int total = 0;
    for (final GroupedSwapRequests group in list) {
      total += group.totalCount;
    }
    return total;
  }



  String _totalLabel(int count) {
    if (count <= 1) return 'عرض واحد';
    if (count == 2) return 'عرضان';
    return '$count عروض';
  }

  String _priorityLabel(GroupedSwapRequests group) {
    if (userType == UserType.seller && group.pendingCount > 0) {
      return '${group.pendingCount} بانتظارك';
    }

    if (userType == UserType.buyer && group.pendingCount > 0) {
      return '${group.pendingCount} بانتظار الرد';
    }

    if (group.acceptedCount > 0) {
      return '${group.acceptedCount} جارٍ الاتفاق';
    }

    if (group.swappedCount > 0) {
      return '${group.swappedCount} مكتمل';
    }

    return _totalLabel(group.totalCount);
  }

  bool _hasPendingStatus(GroupedSwapRequests group) {
    return group.pendingCount > 0 || _priorityLabel(group).contains('بانتظار');
  }

  @override
  Widget build(BuildContext context) {
    final List<GroupedSwapRequests> list = groups;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: _kSoftBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kBorder, width: 1),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0F0C587A),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  emptyText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PsColors.textColor3,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              )
            else
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  reverse: false,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final GroupedSwapRequests group = list[index];
                    final bool isSelected = selectedGroupKey == group.groupKey;
                    final bool hasPending = _hasPendingStatus(group);

                    return _CompactProductRequestCard(
                      title: _productTitle(group.anchorProduct),
                      image: _imageProviderFor(group.anchorProduct),
                      totalLabel: _totalLabel(group.totalCount),
                      priorityLabel: _priorityLabel(group),
                      isPending: hasPending,
                      isSelected: isSelected,
                      onTap: () => onSelected(group),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _CompactProductRequestCard extends StatelessWidget {
  const _CompactProductRequestCard({
    required this.title,
    required this.image,
    required this.totalLabel,
    required this.priorityLabel,
    required this.isPending,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final ImageProvider image;
  final String totalLabel;
  final String priorityLabel;
  final bool isPending;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(18);

    final Color borderColor = isSelected
        ? const Color(0xFF63CAD6)
        : Colors.white;

    final Color statusBg = isPending
        ? SwapRequestsProductsPickerSection._kWarningBg
        : const Color(0xFFEAF7FA);

    final Color statusText = isPending
        ? SwapRequestsProductsPickerSection._kWarningText
        : SwapRequestsProductsPickerSection._kPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isSelected
                ? const Color(0x1F24A9C4)
                : const Color(0x09011934),
            blurRadius: isSelected ? 14 : 7,
            offset: Offset(0, isSelected ? 6 : 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Row(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 54,
                        height: 68,
                        child: Image(
                          image: image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFEAF6FA),
                              child: const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF8AA6B8),
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (isPending && !isSelected)
                      PositionedDirectional(
                        top: -5,
                        end: -5,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4B23E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      )
                    else if (isSelected)
                      PositionedDirectional(
                        top: -5,
                        end: -5,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: BoxDecoration(
                            color: SwapRequestsProductsPickerSection._kAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                          SwapRequestsProductsPickerSection._kPrimaryDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        totalLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SwapRequestsProductsPickerSection._kMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.2,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            priorityLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusText,
                              fontWeight: FontWeight.w900,
                              fontSize: 9.4,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}