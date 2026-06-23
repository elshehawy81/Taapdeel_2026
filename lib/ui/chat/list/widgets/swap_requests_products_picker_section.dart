import 'package:flutter/material.dart';
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
  static const Color _kPrimaryDark = Color(0xFF123B52);
  static const Color _kAccent = Color(0xFF19D4E2);
  static const Color _kSoftBg = Color(0xFFF4FCFE);
  static const Color _kBorder = Color(0xFFD8EFF5);
  static const Color _kWarning = Color(0xFFFFB020);
  static const Color _kWarningText = Color(0xFF8A5A00);

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

  String _headerTitle() {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }

    return userType == UserType.seller
        ? 'اختر منتجك'
        : 'اختر المنتج';
  }

  String _helperText() {
    return userType == UserType.seller
        ? 'اختيار المنتج يغير الطلبات المستلمة أسفله'
        : 'اختيار المنتج يغير الطلبات المرسلة أسفله';
  }

  String _countLabel(int count) {
    if (count <= 1) return 'طلب';
    if (count == 2) return 'طلبين';
    return '$count طلب';
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

    return _countLabel(group.totalCount);
  }

  bool _hasPendingStatus(GroupedSwapRequests group) {
    return group.pendingCount > 0 || _priorityLabel(group).contains('بانتظار');
  }

  int _selectedRequestsCount() {
    for (final GroupedSwapRequests group in groups) {
      if (group.groupKey == selectedGroupKey) {
        return group.totalCount;
      }
    }
    return groups.isEmpty ? 0 : groups.first.totalCount;
  }

  @override
  Widget build(BuildContext context) {
    final List<GroupedSwapRequests> list = groups;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: list.isEmpty ? null : 74,
        padding: const EdgeInsetsDirectional.only(
          start: 9,
          end: 7,
          top: 7,
          bottom: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _kBorder,
            width: 1,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0D0C587A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: list.isEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF607684),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        )
            : Row(
          children: <Widget>[
            _PickerIntroPill(
              title: _headerTitle(),
              subtitle: _helperText(),
              count: _selectedRequestsCount(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final GroupedSwapRequests group = list[index];
                  final bool selected = selectedGroupKey == group.groupKey;
                  final bool hasPending = _hasPendingStatus(group);

                  return _RequestProductImageChip(
                    imageProvider: _imageProviderFor(group.anchorProduct),
                    selected: selected,
                    countText: _countLabel(group.totalCount),
                    priorityText: _priorityLabel(group),
                    hasPending: hasPending,
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

class _PickerIntroPill extends StatelessWidget {
  const _PickerIntroPill({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 42,
      padding: const EdgeInsetsDirectional.only(start: 9, end: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SwapRequestsProductsPickerSection._kSoftBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFBFEAF0),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SwapRequestsProductsPickerSection._kPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.6,
                    height: 1,
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

class _RequestProductImageChip extends StatelessWidget {
  const _RequestProductImageChip({
    required this.imageProvider,
    required this.selected,
    required this.countText,
    required this.priorityText,
    required this.hasPending,
    required this.onTap,
  });

  final ImageProvider imageProvider;
  final bool selected;
  final String countText;
  final String priorityText;
  final bool hasPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(14);

    return SizedBox(
      width: selected ? 74 : 52,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: selected
                          ? SwapRequestsProductsPickerSection._kAccent
                          : const Color(0xFFD3E9F0),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: <BoxShadow>[
                      if (selected)
                        const BoxShadow(
                          color: Color(0x2A21C9D7),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      else
                        const BoxShadow(
                          color: Color(0x0D0C587A),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFE8F4F8),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF8AA6B8),
                                size: 18,
                              ),
                            );
                          },
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.45),
                                ],
                              ),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          bottom: 5,
                          start: 5,
                          end: 5,
                          child: Text(
                            selected ? priorityText : countText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 8.7,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (selected)
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
            )
          else if (hasPending)
            PositionedDirectional(
              top: -5,
              end: -5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: SwapRequestsProductsPickerSection._kWarning,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.white,
                  size: 11,
                ),
              ),
            ),
          if (!selected)
            PositionedDirectional(
              bottom: -5,
              start: 5,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hasPending
                      ? SwapRequestsProductsPickerSection._kWarning
                      : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.2,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  countText,
                  maxLines: 1,
                  style: TextStyle(
                    color: hasPending
                        ? SwapRequestsProductsPickerSection._kWarningText
                        : SwapRequestsProductsPickerSection._kPrimaryDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 8.4,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
