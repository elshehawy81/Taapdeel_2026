import 'package:flutter/material.dart';

import 'wish_item_entry_view.dart';
import 'package:taapdeel/viewobject/product.dart';

class WishItemEntryContainerView extends StatefulWidget {
  const WishItemEntryContainerView({
    Key? key,
    required this.flag,
    required this.item,
    this.onItemUploaded,
  }) : super(key: key);

  final String flag;
  final Product item;
  final Function? onItemUploaded;

  @override
  State<WishItemEntryContainerView> createState() =>
      _WishItemEntryContainerViewState();
}

class _WishItemEntryContainerViewState
    extends State<WishItemEntryContainerView> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WishItemEntryView(
      flag: widget.flag,
      item: widget.item,
      animationController: _animationController,
      onItemUploaded: widget.onItemUploaded,
      // عدد الصور المسموح بها – عدّل الرقم لو عندك constant مخصوص
      maxImageCount: 10,
    );
  }
}
