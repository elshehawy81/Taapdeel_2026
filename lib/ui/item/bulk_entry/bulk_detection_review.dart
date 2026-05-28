// ─────────────────────────────────────────────────────────────────────────────
// bulk_detection_review.dart
// شاشة مراجعة المنتجات المكتشفة من AI قبل الإدخال
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/utils/utils.dart';

import '../../../constant/route_paths.dart';
import 'bulk_item_data.dart';
import 'bulk_item_defaults.dart';
import 'bulk_item_queue_view.dart';

class BulkDetectionReviewScreen extends StatefulWidget {
  const BulkDetectionReviewScreen({
    Key? key,
    required this.detectedItems,
    required this.sourceImagePaths,
    required this.maxItems,
    required this.defaults,
  }) : super(key: key);

  final List<BulkItemData> detectedItems;
  final List<String> sourceImagePaths;
  final int maxItems;
  final BulkItemDefaults defaults;

  @override
  State<BulkDetectionReviewScreen> createState() =>
      _BulkDetectionReviewScreenState();
}

class _BulkDetectionReviewScreenState
    extends State<BulkDetectionReviewScreen> {
  late List<BulkItemData> _items;
  final Set<int> _selectedIndices = <int>{};

  @override
  void initState() {
    super.initState();
    _items = List<BulkItemData>.from(widget.detectedItems);
    // نحدد كل المنتجات افتراضياً
    for (int i = 0; i < _items.length; i++) {
      _selectedIndices.add(i);
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _selectedIndices.remove(index);
      // نعيد حساب الـ indices
      final Set<int> updated = <int>{};
      for (final int idx in _selectedIndices) {
        if (idx < index) updated.add(idx);
        if (idx > index) updated.add(idx - 1);
      }
      _selectedIndices
        ..clear()
        ..addAll(updated);
    });
  }

  void _addManualItem() {
    showDialog<String>(
      context: context,
      builder: (_) {
        final TextEditingController ctrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PsDimens.space16)),
          title: const Text('أضف منتج يدوياً',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            textDirection: TextDirection.rtl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'اسم المنتج',
              border: OutlineInputBorder(),
            ),
            onSubmitted: Navigator.of(context).pop,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: PsColors.primary500),
              onPressed: () => Navigator.pop(context, ctrl.text),
              child:
              const Text('إضافة', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((String? name) {
      if (name != null && name.trim().isNotEmpty) {
        setState(() {
          _items.add(BulkItemData(title: name.trim()));
          _selectedIndices.add(_items.length - 1);
        });
      }
    });
  }

  void _editTitle(int index) {
    showDialog<String>(
      context: context,
      builder: (_) {
        final TextEditingController ctrl =
        TextEditingController(text: _items[index].title);
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PsDimens.space16)),
          title: const Text('تعديل اسم المنتج',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            textDirection: TextDirection.rtl,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onSubmitted: Navigator.of(context).pop,
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: PsColors.primary500),
              onPressed: () => Navigator.pop(context, ctrl.text),
              child:
              const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((String? newName) {
      if (newName != null && newName.trim().isNotEmpty) {
        setState(() {
          _items[index] = _items[index].copyWith(title: newName.trim());
        });
      }
    });
  }

  Future<void> _proceedToQueue() async {
    final List<BulkItemData> selected =
    _selectedIndices.map((int i) => _items[i]).toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر منتجاً واحداً على الأقل')),
      );
      return;
    }

    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => BulkItemQueueView(
          items: selected,
          sourceImagePaths: widget.sourceImagePaths,
          maxItems: widget.maxItems,
          defaults: widget.defaults,
        ),
      ),
    );

    if (!mounted) return;

    // نرجع النتيجة للصفحة الأساسية BulkItemEntryView،
    // وهي بدورها تنفذ نفس منطق المنتج الواحد: goToProfileTab(refresh: true).
    if (completed == true) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutePaths.home, // أو '/'
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedCount = _selectedIndices.length;

    return Scaffold(
      backgroundColor: PsColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: PsColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'مراجعة المنتجات المكتشفة',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Utils.isLightMode(context)
                ? PsColors.primary500
                : PsColors.primaryDarkWhite,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Utils.isLightMode(context)
              ? PsColors.primary500
              : PsColors.primaryDarkWhite,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: <Widget>[
          // ─── Header info banner ───
          _BulkReviewBanner(
            totalFound: _items.length,
            selectedCount: selectedCount,
          ),

          // ─── Grid ───
          Expanded(
            child: _items.isEmpty
                ? _EmptyState(onAddManual: _addManualItem)
                : GridView.builder(
              padding: const EdgeInsets.all(PsDimens.space12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: PsDimens.space12,
                crossAxisSpacing: PsDimens.space12,
                childAspectRatio: 0.78,
              ),
              itemCount: _items.length + 1, // +1 for "add" card
              itemBuilder: (BuildContext ctx, int i) {
                if (i == _items.length) {
                  return _AddItemCard(onTap: _addManualItem);
                }
                return _DetectedItemCard(
                  item: _items[i],
                  isSelected: _selectedIndices.contains(i),
                  onToggleSelect: () {
                    setState(() {
                      if (_selectedIndices.contains(i)) {
                        _selectedIndices.remove(i);
                      } else {
                        _selectedIndices.add(i);
                      }
                    });
                  },
                  onDelete: () => _removeItem(i),
                  onEditTitle: () => _editTitle(i),
                );
              },
            ),
          ),

          // ─── Bottom action ───
          _BottomBar(
            selectedCount: selectedCount,
            onProceed: _proceedToQueue,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BulkReviewBanner extends StatelessWidget {
  const _BulkReviewBanner({
    required this.totalFound,
    required this.selectedCount,
  });
  final int totalFound;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
          PsDimens.space12, PsDimens.space4, PsDimens.space12, PsDimens.space4),
      padding: const EdgeInsets.symmetric(
          horizontal: PsDimens.space16, vertical: PsDimens.space12),
      decoration: BoxDecoration(
        color: PsColors.primary500.withOpacity(0.08),
        borderRadius: BorderRadius.circular(PsDimens.space12),
        border: Border.all(color: PsColors.primary500.withOpacity(0.2)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(Icons.auto_awesome_rounded,
              color: PsColors.primary500, size: 20),
          const SizedBox(width: PsDimens.space8),
          Expanded(
            child: Text(
              'اكتشف AI عدد $totalFound منتج — محدد $selectedCount للنشر',
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: PsColors.primary500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectedItemCard extends StatelessWidget {
  const _DetectedItemCard({
    required this.item,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onDelete,
    required this.onEditTitle,
  });

  final BulkItemData item;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onDelete;
  final VoidCallback onEditTitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Utils.isLightMode(context) ? Colors.white : Colors.grey[900],
          borderRadius: BorderRadius.circular(PsDimens.space12),
          border: Border.all(
            color:
            isSelected ? PsColors.primary500 : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
            BoxShadow(
              color: PsColors.primary500.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : <BoxShadow>[],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ─── صورة أو placeholder ───
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(PsDimens.space12)),
                  child: (item.croppedImagePath != null &&
                      item.croppedImagePath!.isNotEmpty)
                      ? Image.file(
                    File(item.croppedImagePath!),
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : (item.sourceImagePath != null &&
                      item.sourceImagePath!.isNotEmpty)
                      ? Image.file(
                    File(item.sourceImagePath!),
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 110,
                    width: double.infinity,
                    color: PsColors.primary500.withOpacity(0.06),
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: PsColors.primary500.withOpacity(0.3),
                    ),
                  ),
                ),
                // Checkbox
                Positioned(
                  top: PsDimens.space6,
                  right: PsDimens.space6,
                  child: _SelectCircle(isSelected: isSelected),
                ),
                // Category badge
                if (item.categoryHint != null)
                  Positioned(
                    bottom: PsDimens.space4,
                    left: PsDimens.space4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.categoryHint!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),

            // ─── Content ───
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(PsDimens.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.conditionHint != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        item.conditionHint!,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600]),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _IconBtn(
                            icon: Icons.edit_outlined,
                            color: PsColors.primary500,
                            onTap: onEditTitle),
                        const SizedBox(width: PsDimens.space4),
                        _IconBtn(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            onTap: onDelete),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectCircle extends StatelessWidget {
  const _SelectCircle({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? PsColors.primary500 : Colors.white.withOpacity(0.9),
        border: Border.all(
          color: isSelected ? PsColors.primary500 : Colors.grey,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _AddItemCard extends StatelessWidget {
  const _AddItemCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.primary500.withOpacity(0.04),
          borderRadius: BorderRadius.circular(PsDimens.space12),
          border: Border.all(
              color: PsColors.primary500.withOpacity(0.3),
              style: BorderStyle.solid,
              width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PsColors.primary500.withOpacity(0.1),
              ),
              child: Icon(Icons.add_rounded,
                  color: PsColors.primary500, size: 26),
            ),
            const SizedBox(height: PsDimens.space8),
            Text(
              'أضف منتج\nيدوياً',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: PsColors.primary500),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddManual});
  final VoidCallback onAddManual;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.search_off_rounded,
              size: 64, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: PsDimens.space16),
          Text(
            'لم يتم اكتشاف منتجات',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.grey),
          ),
          const SizedBox(height: PsDimens.space16),
          ElevatedButton.icon(
            onPressed: onAddManual,
            icon: const Icon(Icons.add_rounded),
            label: const Text('أضف منتجاً يدوياً'),
            style: ElevatedButton.styleFrom(
                backgroundColor: PsColors.primary500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PsDimens.space8))),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar(
      {required this.selectedCount, required this.onProceed});
  final int selectedCount;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(PsDimens.space16, PsDimens.space12,
          PsDimens.space16, MediaQuery.of(context).padding.bottom + PsDimens.space12),
      decoration: BoxDecoration(
        color: PsColors.backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: selectedCount > 0 ? onProceed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: PsColors.primary500,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PsDimens.space12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ابدأ إدخال $selectedCount منتج',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(width: PsDimens.space8),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
