import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/product.dart';

import 'item_entry_view_base.dart';

/// Single product entry screen only.
///
/// Bulk-specific parameters must not be passed here.
/// Use BulkItemEntryEditorView through ItemEntryContainerView for the bulk flow.
class ItemEntryView extends StatelessWidget {
  const ItemEntryView({
    Key? key,
    this.flag,
    this.item,
    required this.animationController,
    this.onItemUploaded,
    required this.maxImageCount,
  }) : super(key: key);

  final AnimationController? animationController;
  final String? flag;
  final Product? item;
  final ValueChanged<String>? onItemUploaded;
  final int maxImageCount;

  @override
  Widget build(BuildContext context) {
    return ItemEntryViewBase(
      key: key,
      flag: flag,
      item: item,
      animationController: animationController,
      onItemUploaded: onItemUploaded,
      maxImageCount: maxImageCount,
    );
  }
}
