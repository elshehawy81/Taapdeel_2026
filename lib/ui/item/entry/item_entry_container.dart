// ─────────────────────────────────────────────────────────────────────────────
// item_entry_container.dart
//
// Router container:
// 1) ItemEntryView = normal single-product add/edit.
// 2) BulkItemEntryEditorView = edit/save one detected item inside bulk queue.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/product.dart';

import '../bulk_entry/bulk_item_data.dart';
import '../bulk_entry/bulk_item_defaults.dart';
import '../bulk_entry/bulk_item_entry_editor_view.dart';
import 'item_entry_view.dart';

class ItemEntryContainerView extends StatefulWidget {
  const ItemEntryContainerView({
    Key? key,
    required this.flag,
    required this.item,
    this.bulkItemData,
    this.bulkDefaults,
    this.onBulkItemDone,
    this.onItemUploaded,
  }) : super(key: key);

  final String flag;
  final Product? item;
  final BulkItemData? bulkItemData;
  final BulkItemDefaults? bulkDefaults;
  final VoidCallback? onBulkItemDone;

  /// Optional Dashboard hook: switch to فرص التبديلات and reload it after upload.
  final ValueChanged<String>? onItemUploaded;

  @override
  ItemEntryContainerViewState createState() => ItemEntryContainerViewState();
}

class ItemEntryContainerViewState extends State<ItemEntryContainerView>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<bool> _requestPop() {
    animationController?.reverse().then<dynamic>((void data) {
      if (!mounted) return;
      Navigator.pop(context, false);
    });
    return Future<bool>.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);
    final bool isBulkMode = widget.bulkItemData != null;

    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
          ),
          backgroundColor: PsColors.backgroundColor,
          iconTheme: Theme.of(context).iconTheme.copyWith(
                color: Utils.isLightMode(context)
                    ? PsColors.primary500
                    : PsColors.primaryDarkWhite,
              ),
          title: isBulkMode
              ? _BulkModeTitle(data: widget.bulkItemData!)
              : Text(
                  Utils.getString(context, 'item_entry__listing_entry'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Utils.isLightMode(context)
                            ? PsColors.primary500
                            : PsColors.primaryDarkWhite,
                      ),
                ),
          elevation: 0,
        ),
        body: isBulkMode
            ? BulkItemEntryEditorView(
                animationController: animationController,
                flag: widget.flag,
                item: widget.item,
                maxImageCount: psValueHolder.maxImageCount,
                bulkItemData: widget.bulkItemData!,
                bulkDefaults: widget.bulkDefaults,
                onBulkItemDone: widget.onBulkItemDone,
              )
            : ItemEntryView(
                animationController: animationController,
                flag: widget.flag,
                item: widget.item,
                maxImageCount: psValueHolder.maxImageCount,
                onItemUploaded: widget.onItemUploaded,
              ),
      ),
    );
  }
}

/// Custom title for bulk mode.
class _BulkModeTitle extends StatelessWidget {
  const _BulkModeTitle({required this.data});

  final BulkItemData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          data.title,
          textDirection: TextDirection.rtl,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Utils.isLightMode(context)
                    ? PsColors.primary500
                    : PsColors.primaryDarkWhite,
              ),
        ),
        if ((data.categoryHint ?? '').trim().isNotEmpty)
          Text(
            data.categoryHint!,
            textDirection: TextDirection.rtl,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
          ),
      ],
    );
  }
}
