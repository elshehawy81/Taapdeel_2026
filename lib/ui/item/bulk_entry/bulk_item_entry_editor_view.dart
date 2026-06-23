import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/product.dart';

import '../entry/item_entry_view_base.dart';
import 'bulk_item_data.dart';
import 'bulk_item_defaults.dart';

/// Editor for ONE item inside the bulk-products queue.
///
/// Do not use this as the main bulk queue screen.
/// The main bulk flow can keep using BulkItemEntryView(maxItems: ...).
class BulkItemEntryEditorView extends StatelessWidget {
  const BulkItemEntryEditorView({
    Key? key,
    this.flag,
    this.item,
    required this.animationController,
    this.onItemUploaded,
    required this.maxImageCount,
    required this.bulkItemData,
    this.bulkDefaults,
    this.onBulkItemDone,
  }) : super(key: key);

  final AnimationController? animationController;
  final String? flag;
  final Product? item;
  final ValueChanged<String>? onItemUploaded;
  final int maxImageCount;
  final BulkItemData bulkItemData;
  final BulkItemDefaults? bulkDefaults;
  final VoidCallback? onBulkItemDone;

  @override
  Widget build(BuildContext context) {
    return ItemEntryViewBase(
      key: key,
      flag: flag,
      item: item,
      animationController: animationController,
      onItemUploaded: onItemUploaded,
      maxImageCount: maxImageCount,
      bulkItemData: bulkItemData,
      bulkDefaults: bulkDefaults,
      onBulkItemDone: onBulkItemDone,
    );
  }
}
