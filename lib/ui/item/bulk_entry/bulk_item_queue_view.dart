// ═══════════════════════════════════════════════════════════════════════════════
// bulk_item_queue_view.dart (FINAL FIXED VERSION)
// ✅ الحل: استبدال pop(true) بـ popUntil((route) => route.isFirst)
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/utils/utils.dart';

import '../entry/item_entry_container.dart';
import 'bulk_item_data.dart';
import 'bulk_item_defaults.dart';

class BulkItemQueueView extends StatefulWidget {
  const BulkItemQueueView({
    Key? key,
    required this.items,
    required this.sourceImagePaths,
    required this.maxItems,
    required this.defaults,
  }) : super(key: key);

  final List<BulkItemData> items;
  final List<String> sourceImagePaths;
  final int maxItems;
  final BulkItemDefaults defaults;

  @override
  State<BulkItemQueueView> createState() => _BulkItemQueueViewState();
}

class _BulkItemQueueViewState extends State<BulkItemQueueView> {
  int _currentIndex = 0;
  int _doneCount = 0;
  bool _allDone = false;
  bool _isOpeningItem = false;
  bool _isCompletingItem = false;
  bool _isDisposed = false;
  bool _completionDialogShown = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted || _isDisposed) return;
    setState(fn);
  }

  Future<void> _openCurrentItem() async {
    if (!mounted || _isDisposed || _isOpeningItem || _allDone) return;

    if (_currentIndex >= widget.items.length) {
      _safeSetState(() => _allDone = true);
      return;
    }

    final int openingIndex = _currentIndex;
    final BulkItemData data = widget.items[openingIndex];

    _safeSetState(() => _isOpeningItem = true);

    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ItemEntryContainerView(
          flag: PsConst.ADD_NEW_ITEM,
          item: null,
          bulkItemData: data,
          bulkDefaults: widget.defaults,
          onBulkItemDone: () => _completeItem(
            sourceIndex: openingIndex,
            closeEditorRoute: true,
          ),
        ),
      ),
    );

    if (!mounted || _isDisposed) return;
    _safeSetState(() => _isOpeningItem = false);

    if (completed == true) {
      _completeItem(
        sourceIndex: openingIndex,
        closeEditorRoute: false,
      );
    }
  }

  void _completeItem({
    required int sourceIndex,
    required bool closeEditorRoute,
  }) {
    if (!mounted || _isDisposed || _isCompletingItem || _allDone) return;

    if (sourceIndex != _currentIndex) return;

    _isCompletingItem = true;

    if (closeEditorRoute) {
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      } catch (_) {}
      _isOpeningItem = false;
    }

    _safeSetState(() {
      _doneCount++;
      _currentIndex++;
    });

    if (!mounted || _isDisposed) {
      _isCompletingItem = false;
      return;
    }

    if (_currentIndex >= widget.items.length) {
      _safeSetState(() => _allDone = true);
      _isCompletingItem = false;
    } else {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted || _isDisposed || _allDone) {
          _isCompletingItem = false;
          return;
        }
        _isCompletingItem = false;
        _openCurrentItem();
      });
    }
  }

  void _skipCurrent() {
    if (!mounted || _isDisposed || _allDone) return;

    _safeSetState(() {
      _currentIndex++;
    });

    if (_currentIndex >= widget.items.length) {
      _safeSetState(() => _allDone = true);
    } else {
      _openCurrentItem();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isOpeningItem = false;
    _isCompletingItem = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: عندما يكون جميع المنتجات مكتملة
    if (_allDone) {
      if (!_completionDialogShown) {
        _completionDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted || _isDisposed) return;

          final int done = _doneCount;

          // عرض Dialog النجاح
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) => _SuccessDialog(doneCount: done),
          );

          if (!mounted || _isDisposed) return;

          // ✅ FIX (سطر واحد فقط):
          // بدل: Navigator.of(context).pop(true);
          // استخدم: حذف جميع الـ Routes والبقاء على الـ Home
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }

      return Scaffold(
        backgroundColor: PsColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: PsColors.backgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const SizedBox.shrink(),
      );
    }

    // الحالة العادية: عرض Queue
    return Scaffold(
      backgroundColor: PsColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: PsColors.backgroundColor,
        elevation: 0,
        title: Text(
          'إضافة المنتجات',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Utils.isLightMode(context)
                ? PsColors.primary500
                : PsColors.primaryDarkWhite,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: Utils.isLightMode(context)
              ? PsColors.primary500
              : PsColors.primaryDarkWhite,
          onPressed: () => _showExitDialog(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(PsDimens.space20),
          child: Column(
            children: <Widget>[
              _BulkProgressHeader(
                currentIndex: _currentIndex,
                total: widget.items.length,
                doneCount: _doneCount,
              ),

              const SizedBox(height: PsDimens.space32),

              if (_currentIndex < widget.items.length)
                _CurrentItemCard(
                  item: widget.items[_currentIndex],
                  index: _currentIndex,
                  total: widget.items.length,
                ),

              const SizedBox(height: PsDimens.space32),

              if (_currentIndex + 1 < widget.items.length) ...<Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'المنتجات التالية:',
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: PsDimens.space8),
                Expanded(
                  child: ListView.separated(
                    itemCount:
                    (widget.items.length - _currentIndex - 1).clamp(0, 5),
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: PsDimens.space8),
                    itemBuilder: (BuildContext ctx, int i) {
                      final int idx = _currentIndex + 1 + i;
                      return _UpcomingItemTile(
                        item: widget.items[idx],
                        number: idx + 1,
                      );
                    },
                  ),
                ),
              ] else
                const Spacer(),

              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skipCurrent,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(PsDimens.space12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: PsDimens.space14),
                      ),
                      child: Text(
                        'تخطي',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: PsDimens.space12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isOpeningItem ? null : () { _openCurrentItem(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PsColors.primary500,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(PsDimens.space12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: PsDimens.space14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: PsDimens.space8),
                          Text(
                            'أدخل المنتج ${_currentIndex + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + PsDimens.space8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExitDialog() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PsDimens.space16)),
        title: const Text('إيقاف الإضافة؟',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'تم إدخال $_doneCount من ${widget.items.length} منتجات.\nهل تريد الخروج؟',
          textDirection: TextDirection.rtl,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('استمرار'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child:
            const Text('خروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pop(false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Helper Widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _BulkProgressHeader extends StatelessWidget {
  const _BulkProgressHeader({
    required this.currentIndex,
    required this.total,
    required this.doneCount,
  });

  final int currentIndex;
  final int total;
  final int doneCount;

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? doneCount / total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: <Widget>[
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'تقدم الإضافة',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$doneCount / $total',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(
                color: PsColors.primary500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: PsDimens.space8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              PsColors.primary500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrentItemCard extends StatelessWidget {
  const _CurrentItemCard({
    required this.item,
    required this.index,
    required this.total,
  });

  final BulkItemData item;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsDimens.space16),
      decoration: BoxDecoration(
        color: Utils.isLightMode(context)
            ? Colors.grey[50]
            : Colors.grey[850],
        borderRadius: BorderRadius.circular(PsDimens.space16),
        border: Border.all(color: PsColors.primary500.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PsColors.primary500.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PsColors.primary500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: PsDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: <Widget>[
                    Text(
                      'المنتج الحالي',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.categoryHint != null) ...<Widget>[
            const SizedBox(height: PsDimens.space12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: PsDimens.space8, vertical: PsDimens.space4),
              decoration: BoxDecoration(
                color: PsColors.primary500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.categoryHint!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PsColors.primary500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingItemTile extends StatelessWidget {
  const _UpcomingItemTile({required this.item, required this.number});
  final BulkItemData item;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PsDimens.space12, vertical: PsDimens.space10),
      decoration: BoxDecoration(
        color: Utils.isLightMode(context)
            ? Colors.grey[50]
            : Colors.grey[850],
        borderRadius: BorderRadius.circular(PsDimens.space10),
        border:
        Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(width: PsDimens.space10),
          Expanded(
            child: Text(
              item.title,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (item.categoryHint != null)
            Text(
              item.categoryHint!,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.doneCount});
  final int doneCount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsDimens.space20)),
      backgroundColor:
      Utils.isLightMode(context) ? Colors.white : Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(PsDimens.space28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF065F46).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF065F46),
                size: 48,
              ),
            ),
            const SizedBox(height: PsDimens.space20),

            Text(
              '🎉 تهانيــنا!',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PsDimens.space12),

            Text(
              'تم إدخال $doneCount منتج بنجاح\nبانتظار موافقة الأدمن ✅',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: PsDimens.space28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PsColors.primary500,
                  padding: const EdgeInsets.symmetric(
                      vertical: PsDimens.space14),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(PsDimens.space12)),
                ),
                child: const Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
