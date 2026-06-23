import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/provider/main_provider.dart';

class OfferListViewAppBar extends StatefulWidget {
  const OfferListViewAppBar(
      {this.selectedIndex = 0,
      this.showElevation = true,
      this.iconSize = 24,
      this.size = 0,
      required this.items,
      required this.onItemSelected})
      : assert(items.length >= 2 && items.length <= 5);

  @override
  _OfferListViewAppBarState createState() {
    return _OfferListViewAppBarState(
        selectedIndexNo: selectedIndex,
        items: items,
        iconSize: iconSize,
        onItemSelected: onItemSelected);
  }

  final int selectedIndex;
  final int size;
  final double iconSize;
  final bool showElevation;
  final List<OfferListViewAppBarItem> items;
  final ValueChanged<int> onItemSelected;
}

class _OfferListViewAppBarState extends State<OfferListViewAppBar> {
  _OfferListViewAppBarState(
      {required this.items,
      this.iconSize,
      this.selectedIndexNo,
      required this.onItemSelected});

  final double? iconSize;
  List<OfferListViewAppBarItem> items;
  int? selectedIndexNo;

  ValueChanged<int> onItemSelected;

  Widget _buildItem(OfferListViewAppBarItem item, bool isSelected, int size) {
    return Card(
      elevation: 3,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
           AnimatedContainer(
            width: PsDimens.space160,
            // height: double.maxFinite,
            duration: const Duration(milliseconds: 200),
            // margin: const EdgeInsets.only(right: PsDimens.space6),
            decoration: BoxDecoration(
              border: Border.all(color: PsColors.activeColor!),
              color: isSelected ? PsColors.primary900 : PsColors.white,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Center(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Icon(Icons.message, //MaterialCommunityIcons.message_text_outline,
                //     color: isSelected ? item.activeColor : item.inactiveColor),
                // const SizedBox(
                //   width: PsDimens.space8,
                // ),
                FittedBox(
                  child:Row(
                    children: [
                      Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                            isSelected ? PsColors.white : PsColors.textColor1,
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal),
                      ),item.size==null||size==0?Text(""):Text(" ("+size.toString()+') '),
                    ],
                  )
                ),
              ],
            )),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(2.0),
          //   child: Text(
          //     '${widget.size}',
          //     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          //         color: isSelected ? PsColors.white : PsColors.activeColor,
          //         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    selectedIndexNo = widget.selectedIndex;
    return Container(
      decoration: BoxDecoration(
          color: PsColors.baseColor,
          boxShadow: <BoxShadow>[
            if (widget.showElevation)
              const BoxShadow(color: Colors.black12, blurRadius: 2)
          ]),
      child: Container(
          margin: const EdgeInsets.only(
              // top: PsDimens.space16,
              bottom: PsDimens.space16,
              left: PsDimens.space8,
              right: PsDimens.space8),
          width: double.infinity,
          height: 40,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final OfferListViewAppBarItem item = items[index];
                int size = item.size == 0
                    ? MainProvider.of(context).swapListP.length
                    : item.size == 1
                        ? MainProvider.of(context).swapListA.length
                        : item.size == 2
                            ? MainProvider.of(context).swapListS.length
                            : MainProvider.of(context).swapListR.length;
                return InkWell(
                  onTap: () {
                    onItemSelected(index);
                    setState(() {
                      selectedIndexNo = index;
                    });
                  },
                  child: _buildItem(item, selectedIndexNo == index, size),
                );
              })),
    );
  }
}

class OfferListViewAppBarItem {
  OfferListViewAppBarItem(
      {required this.title,
      this.size,
      Color? activeColor,
      Color? activeBackgroundColor,
      Color? inactiveColor,
      Color? inactiveBackgroundColor})
      : activeColor = activeColor ?? PsColors.white,
        activeBackgroundColor = activeBackgroundColor ?? PsColors.primary900,
        inactiveColor = inactiveColor ?? PsColors.grey,
        inactiveBackgroundColor = inactiveBackgroundColor ?? PsColors.white;
  final String title;
  final int? size;
  final Color? activeColor;
  final Color? activeBackgroundColor;
  final Color? inactiveColor;
  final Color inactiveBackgroundColor;
}
