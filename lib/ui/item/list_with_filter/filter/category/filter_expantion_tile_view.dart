import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/provider/subcategory/sub_category_provider.dart';
import 'package:taapdeel/repository/sub_category_repository.dart';
import 'package:taapdeel/ui/common/ps_expansion_tile.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';

class FilterExpantionTileView extends StatefulWidget {
  const FilterExpantionTileView({
    Key? key,
    this.selectedData,
    this.category,
    required this.onSubCategoryClick,
  }) : super(key: key);

  final dynamic selectedData;
  final Category? category;

  /// callback لما يختار SubCategory
  final Function(Map<String, String?> data) onSubCategoryClick;

  @override
  State<StatefulWidget> createState() => _FilterExpantionTileViewState();
}

class _FilterExpantionTileViewState extends State<FilterExpantionTileView> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final SubCategoryRepository subCategoryRepository =
    Provider.of<SubCategoryRepository>(context);
    final PsValueHolder valueHolder = Provider.of<PsValueHolder>(context);

    return ChangeNotifierProvider<SubCategoryProvider>(
      lazy: false,
      create: (BuildContext context) {
        final SubCategoryProvider provider =
        SubCategoryProvider(repo: subCategoryRepository);

        provider.subCategoryParameterHolder.catId = widget.category!.catId;
        provider.categoryId = widget.category!.catId!;
        provider.loadAllSubCategoryList(
          provider.subCategoryParameterHolder.toMap(),
          valueHolder.loginUserId ?? '',
        );

        return provider;
      },
      child: Consumer<SubCategoryProvider>(
        builder: (BuildContext context, SubCategoryProvider provider, Widget? _) {
          return PsExpansionTile(
            initiallyExpanded: false,
            backgroundColor: PsColors.backgroundColor,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.category!.catName ?? '',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (widget.category!.catId ==
                    widget.selectedData[PsConst.CATEGORY_ID])
                  IconButton(
                    icon: Icon(
                      Icons.playlist_add_check,
                      color: Theme.of(context)
                          .iconTheme
                          .copyWith(color: PsColors.activeColor)
                          .color,
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.subCategoryList.data!.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: PsDimens.space16,
                          ),
                          child: Text(
                            index == 0
                                ? Utils.getString(
                              context,
                              'product_list__category_all',
                            )
                                : provider
                                .subCategoryList.data![index - 1].name!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        _buildCheckIcon(context, provider, index),
                      ],
                    ),
                    onTap: () {
                      final Map<String, String?> dataHolder =
                      <String, String?>{};

                      if (index == 0) {
                        dataHolder[PsConst.CATEGORY_ID] =
                            widget.category!.catId;
                        dataHolder[PsConst.SUB_CATEGORY_ID] = '';
                        dataHolder[PsConst.CATEGORY_NAME] =
                            widget.category!.catName;
                      } else {
                        dataHolder[PsConst.CATEGORY_ID] =
                            widget.category!.catId;
                        dataHolder[PsConst.SUB_CATEGORY_ID] =
                            provider.subCategoryList.data![index - 1].id;
                        dataHolder[PsConst.CATEGORY_NAME] =
                            provider.subCategoryList.data![index - 1].name;
                      }

                      widget.onSubCategoryClick(dataHolder);
                    },
                  );
                },
              ),
            ],
            onExpansionChanged: (bool expanding) {
              setState(() => isExpanded = expanding);
            },
          );
        },
      ),
    );
  }

  /// يبني أيقونة الـ check اللي على يمين كل سطر حسب الاختيار الحالي
  Widget _buildCheckIcon(
      BuildContext context,
      SubCategoryProvider provider,
      int index,
      ) {
    final String selectedCatId =
    widget.selectedData[PsConst.CATEGORY_ID] as String;
    final String selectedSubCatId =
    widget.selectedData[PsConst.SUB_CATEGORY_ID] as String;

    // أول صف = All
    if (index == 0 &&
        widget.category!.catId == selectedCatId &&
        selectedSubCatId == '') {
      return IconButton(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context)
              .iconTheme
              .copyWith(color: PsColors.activeColor)
              .color,
        ),
        onPressed: () {},
      );
    }

    // باقي الـ subcategories
    if (index != 0 &&
        selectedSubCatId ==
            provider.subCategoryList.data![index - 1].id) {
      return IconButton(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () {},
      );
    }

    return const SizedBox.shrink();
  }
}
