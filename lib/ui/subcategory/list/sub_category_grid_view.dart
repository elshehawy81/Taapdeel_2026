import 'dart:async'; // 👈 عشان الـ Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/provider/subcategory/sub_category_provider.dart';
import 'package:taapdeel/repository/sub_category_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/subcategory/item/sub_category_grid_item.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/subscribe_parameter_holder.dart';
import 'package:taapdeel/viewobject/sub_category.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../api/common/ps_resource.dart';
import '../../../constant/route_paths.dart';
import '../../../viewobject/api_status.dart';
import '../../../viewobject/holder/intent_holder/product_list_intent_holder.dart';
import '../../Foryou/home_provider.dart';
import '../../common/dialog/error_dialog.dart';

// Taapdeel Scaffold
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

class SubCategoryGridView extends StatefulWidget {
  const SubCategoryGridView({this.category, this.onBoarding = false});

  final Category? category;
  final bool onBoarding;

  @override
  _ModelGridViewState createState() {
    return _ModelGridViewState();
  }
}

class _ModelGridViewState extends State<SubCategoryGridView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  SubCategoryProvider? _subCategoryProvider;

  AnimationController? animationController;
  Animation<double>? animation;
  bool subscribeNoti = false;
  List<String?> subscribeList = <String?>[];
  List<String?> unsubscribeListWithMB = <String?>[];
  List<String?> tempList = <String?>[];
  bool needToAdd = true;

  SubCategoryRepository? repo1;
  PsValueHolder? valueHolder;

  // 👇 Debounce Timer
  Timer? _debounceTimer;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final String? categId = widget.category!.catId;
        Utils.psPrint('CategoryId number is $categId');

        _subCategoryProvider!.nextSubCategoryList(
          _subCategoryProvider!.subCategoryParameterHolder.toMap(),
          Utils.checkUserLoginId(valueHolder!),
        );
      }
    });
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    animation = null;
    _debounceTimer?.cancel(); // 👈 إلغاء الـ Timer لو الشاشة اتقفلت
    super.dispose();
  }

  // ⚠️ مهم: عشان لما يتغيّر الـ tab (التصنيف الرئيسي) نعيد تحميل السب كاتيجوري
  @override
  void didUpdateWidget(covariant SubCategoryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.category?.catId != oldWidget.category?.catId &&
        _subCategoryProvider != null) {
      // حدّث الـ catId في الـ provider
      _subCategoryProvider!.subCategoryParameterHolder.catId =
          widget.category!.catId;
      _subCategoryProvider!.categoryId = widget.category!.catId!;

      // نظّف الـ tempList بحيث الـ selected تتبني من الداتا الجديدة
      tempList.clear();
      needToAdd = true;

      _subCategoryProvider!.resetSubCategoryList(
        _subCategoryProvider!.subCategoryParameterHolder.toMap(),
        Utils.checkUserLoginId(_subCategoryProvider!.psValueHolder!),
      );
    }
  }

  /// Debounce Wrapper
  /// يتم استدعاؤه مع كل Tap، لكنه لا ينفّذ الـ API إلا بعد آخر Tap بـ delay
  void _scheduleAutoUpdateSubscription() {
    // لو فيه Timer سابق، نلغيه
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      _autoUpdateSubscription();
    });
  }

  /// Auto-Save: نفس لوجيك Update_Subscription القديم لكن بيشتغل تلقائيًا
  Future<void> _autoUpdateSubscription() async {
    // لو مفيش يوزر لوج إن مفيش داعي نكلم السيرفر
    if (valueHolder == null ||
        valueHolder!.loginUserId == null ||
        valueHolder!.loginUserId == '') {
      return;
    }

    // نفس الشرط القديم: لو مفيش أي عناصر في الـ HomeProvider
    if (HomeProvider.of(context, listen: false).retrieveList().isEmpty) {
      setState(() {
        subscribeNoti = false;
      });
      return;
    }

    // لو مفيش أي تغييرات فعلية
    if (subscribeList.isEmpty && unsubscribeListWithMB.isEmpty) {
      return;
    }

    final List<String?> subscribeListWithMB = <String?>[];
    for (String? temp in subscribeList) {
      subscribeListWithMB.add('${temp!}_MB');
    }

    final SubscribeParameterHolder holder = SubscribeParameterHolder(
      userId: valueHolder!.loginUserId ?? '',
      catId: widget.category!.catId!,
      selectedsubCatId: subscribeListWithMB,
    );

    // بدون Progress Dialog ولا Success Dialog
    final PsResource<ApiStatus> subscribeStatus =
    await _subCategoryProvider!.postSubCategorySubscribe(holder.toMap());

    if (!mounted) {
      return;
    }

    if (subscribeStatus.status == PsStatus.SUCCESS) {
      // نفس لوجيك الـ FCM القديم
      Utils.subscribeToModelTopics(List<String>.from(
          Set<String>.from(subscribeListWithMB)
              .difference(Set<String>.from(unsubscribeListWithMB))));
      Utils.unSubsribeFromModelTopics(unsubscribeListWithMB);

      setState(() {
        subscribeNoti = false;
        subscribeList.clear();
        unsubscribeListWithMB.clear();
        needToAdd = false;
      });

      // 👇 Toast / SnackBar صغير
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('تم تحديث تفضيلاتك'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
    } else {
      // في حالة الفشل نظهر ErrorDialog خفيف
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'subscribe failed.'),
          );
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    repo1 = Provider.of<SubCategoryRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    return TaapdeelScaffold(
      appBar: null, // 👈 مفيش AppBar
      safeTop: true,
      safeBottom: true,
      padding: EdgeInsets.zero,
      body: ChangeNotifierProvider<SubCategoryProvider?>(
        lazy: false,
        create: (BuildContext context) {
          _subCategoryProvider =
              SubCategoryProvider(repo: repo1, psValueHolder: valueHolder);
          _subCategoryProvider!.subCategoryParameterHolder.catId =
              widget.category!.catId;
          _subCategoryProvider!.categoryId = widget.category!.catId!;
          _subCategoryProvider!.loadAllSubCategoryList(
            _subCategoryProvider!.subCategoryParameterHolder.toMap(),
            Utils.checkUserLoginId(_subCategoryProvider!.psValueHolder!),
          );
          return _subCategoryProvider;
        },
        child: Consumer<SubCategoryProvider>(
          builder:
              (BuildContext context, SubCategoryProvider provider, Widget? child) {
            return Container(
              height: double.infinity,
              color: const Color(0xE6E0F1FF),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(PsDimens.space8),
                          padding: const EdgeInsets.all(PsDimens.space8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.25),
                          ),
                          child: RefreshIndicator(
                            onRefresh: () {
                              return _subCategoryProvider!
                                  .resetSubCategoryList(
                                _subCategoryProvider!
                                    .subCategoryParameterHolder
                                    .toMap(),
                                Utils.checkUserLoginId(valueHolder!),
                              );
                            },
                            child: CustomScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: false,
                              slivers: <Widget>[
                                SliverGrid(
                                  gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 170.0,
                                    childAspectRatio: 1.05,
                                    mainAxisSpacing: 3,
                                    crossAxisSpacing: 12,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                      if (provider.subCategoryList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                          baseColor: colorScheme
                                              .surfaceContainerHighest,
                                          highlightColor: colorScheme.surface,
                                          child: const Column(
                                            children: <Widget>[
                                              FrameUIForLoading(),
                                              FrameUIForLoading(),
                                              FrameUIForLoading(),
                                              FrameUIForLoading(),
                                              FrameUIForLoading(),
                                              FrameUIForLoading(),
                                            ],
                                          ),
                                        );
                                      } else if (provider
                                          .subCategoryList.data !=
                                          null &&
                                          provider.subCategoryList.data!
                                              .isNotEmpty) {
                                        final int count = provider
                                            .subCategoryList.data!.length;
                                        final SubCategory? subCategory =
                                        provider.subCategoryList
                                            .data![index];

                                        if (subCategory?.isSubscribe != null &&
                                            subCategory!.isSubscribe ==
                                                PsConst.ONE &&
                                            !tempList.contains(subCategory.id) &&
                                            needToAdd) {
                                          tempList.add(subCategory.id);
                                        }

                                        return SubCategoryGridItem(
                                          selected: (valueHolder!.loginUserId !=
                                              null &&
                                              valueHolder!.loginUserId != '')
                                              ? tempList
                                              .contains(subCategory!.id)
                                              : HomeProvider.of(context,
                                              listen: false)
                                              .isSubCategorySelected(
                                              subCategory:
                                              subCategory!),
                                          subScribeNoti: subscribeNoti,
                                          tempList: tempList,
                                          subCategory: subCategory!,
                                          onTap: () {
                                            if (widget.onBoarding) {
                                              setState(() {
                                                provider.selectedItems[index] =
                                                !provider
                                                    .selectedItems[index];

                                                HomeProvider.of(context,
                                                    listen: false)
                                                    .toggleSelection(
                                                    subCategory:
                                                    subCategory);
                                              });

                                              setState(() {
                                                if (tempList.contains(
                                                    subCategory.id)) {
                                                  tempList
                                                      .remove(subCategory.id);
                                                  unsubscribeListWithMB.add(
                                                      '${subCategory.id!}_MB');
                                                } else {
                                                  tempList.add(subCategory.id);
                                                  unsubscribeListWithMB.remove(
                                                      '${subCategory.id!}_MB');
                                                }

                                                if (subscribeList.contains(
                                                    subCategory.id)) {
                                                  subscribeList
                                                      .remove(subCategory.id);
                                                } else {
                                                  subscribeList
                                                      .add(subCategory.id);
                                                }
                                                needToAdd = false;
                                              });

                                              // 🔁 Debounced Auto-Save بعد آخر تغيير
                                              _scheduleAutoUpdateSubscription();
                                            } else {
                                              provider
                                                  .subCategoryByCatIdParamenterHolder
                                                  .mile = valueHolder!.mile;
                                              provider
                                                  .subCategoryByCatIdParamenterHolder
                                                  .catId = provider
                                                  .subCategoryList
                                                  .data![index]
                                                  .catId;
                                              provider
                                                  .subCategoryByCatIdParamenterHolder
                                                  .subCatId = provider
                                                  .subCategoryList
                                                  .data![index]
                                                  .id;
                                              provider
                                                  .subCategoryByCatIdParamenterHolder
                                                  .itemLocationId =
                                                  valueHolder!.locationId;
                                              provider
                                                  .subCategoryByCatIdParamenterHolder
                                                  .itemLocationName =
                                                  valueHolder!.locactionName;
                                              if (valueHolder!.isSubLocation ==
                                                  PsConst.ONE) {
                                                provider
                                                    .subCategoryByCatIdParamenterHolder
                                                    .itemLocationTownshipId =
                                                    valueHolder!
                                                        .locationTownshipId;
                                                provider
                                                    .subCategoryByCatIdParamenterHolder
                                                    .itemLocationTownshipName =
                                                    valueHolder!
                                                        .locationTownshipName;
                                              }
                                              Navigator.pushNamed(
                                                context,
                                                RoutePaths.filterProductList,
                                                arguments:
                                                ProductListIntentHolder(
                                                  appBarTitle: provider
                                                      .subCategoryList
                                                      .data![index]
                                                      .name,
                                                  productParameterHolder: provider
                                                      .subCategoryByCatIdParamenterHolder,
                                                ),
                                              );
                                            }
                                          },
                                          onBoarding: widget.onBoarding,
                                          animationController:
                                          animationController,
                                          animation: Tween<double>(
                                              begin: 0.0, end: 1.0)
                                              .animate(
                                            CurvedAnimation(
                                              parent: animationController!,
                                              curve: Interval(
                                                (1 / count) * index,
                                                1.0,
                                                curve: Curves.fastOutSlowIn,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                    childCount:
                                    provider.subCategoryList.data!.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PSProgressIndicator(
                          provider.subCategoryList.status,
                          message: provider.subCategoryList.message,
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void updateCheckBox(BuildContext context, SubCategoryProvider provider) {
  if (provider.isChecked) {
    provider.isChecked = false;
  } else {
    provider.isChecked = true;
  }
}

class FrameUIForLoading extends StatelessWidget {
  const FrameUIForLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          height: 70,
          width: 70,
          margin: const EdgeInsets.all(PsDimens.space16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 15,
                margin: const EdgeInsets.all(PsDimens.space8),
                decoration: BoxDecoration(
                  color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 15,
                margin: const EdgeInsets.all(PsDimens.space8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
