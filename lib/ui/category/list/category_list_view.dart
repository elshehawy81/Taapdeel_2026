import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/category/category_provider.dart';
import 'package:taapdeel/provider/subcategory/sub_category_provider.dart';
import 'package:taapdeel/repository/category_repository.dart';
import 'package:taapdeel/repository/sub_category_repository.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_card.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/category_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/subscribe_parameter_holder.dart';
import 'package:taapdeel/viewobject/sub_category.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../category_personalization.dart';
import '../../Foryou/home_provider.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({
    Key? key,
    this.onBoarding = false,
    this.home = false,
    this.onTap,
    this.onLoginTap,
  }) : super(key: key);

  final bool onBoarding;
  final bool home;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLoginTap;

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView>
    with TickerProviderStateMixin {
  final CategoryParameterHolder categoryParameterHolder =
  CategoryParameterHolder();

  late final AnimationController _animationController;
  PsValueHolder? _psValueHolder;

  // ✅ PageView with Peek
  late final PageController _pageController;

  int _currentPage = 0;

  // Debounced autosave
  Timer? _autoSaveTimer;
  final Set<String> _touchedCatIds = <String>{};
  final Set<String> _hydratedSubKeys = <String>{};
  bool _localRestoreTried = false;

  // UI colors
  static const Color _bg = Color(0xE6E0F1FF);

  // ✅ unified chip color (ALL chips same)
  static const Color _chipBg = Color(0xFFFFFFFF);
  static const Color _chipBorder = Color(0xFFFFFFFF);

  // ✅ Assets mapping for MAIN categories
  static const Map<String, String> _mainCategoryHeroAssetsByKey =
  <String, String>{
    'toys': 'assets/images/products/toys.png',
    'electronics': 'assets/images/products/electronics.png',
    'sports': 'assets/images/products/sports.png',
    'home': 'assets/images/products/home.png',
    'fashion_beauty': 'assets/images/products/fashion_beauty.png',
    'school_supplies': 'assets/images/products/school.png',
    'books': 'assets/images/products/books.png',
    'hobbies': 'assets/images/products/hobbies.png',
    'moms': 'assets/images/products/moms.png',
    'clothes': 'assets/images/products/clothes.png',
    'other': 'assets/images/products/other.png',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: PsConfig.animation_duration,
      vsync: this,
    );

    // ✅ Peek: show part of next page
    _pageController = PageController(viewportFraction: 0.92);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSavedSelectionsBestEffort();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<bool> _requestPop() {
    _animationController.reverse().then<void>((_) {
      if (!mounted) return;
      Navigator.pop<Category?>(context, null);
    });
    return Future<bool>.value(false);
  }

  String? _readUserGender(PsValueHolder? holder) {
    try {
      final dynamic d = holder as dynamic;
      final dynamic v = d.userGender;
      if (v is String && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return null;
  }

  String? _readUserAgeRange(PsValueHolder? holder) {
    try {
      final dynamic d = holder as dynamic;
      final dynamic v = d.userAgeRange;
      if (v is String && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return null;
  }

  void _restoreSavedSelectionsBestEffort() {
    if (!mounted || _localRestoreTried) return;
    _localRestoreTried = true;

    final HomeProvider homeProvider = HomeProvider.of(context, listen: false);

    // Different app versions/templates usually expose different restore names.
    // These dynamic calls are intentionally best-effort and safely ignored
    // when the method does not exist in your HomeProvider implementation.
    try {
      (homeProvider as dynamic).loadList();
    } catch (_) {}
    try {
      (homeProvider as dynamic).loadSelectedList();
    } catch (_) {}
    try {
      (homeProvider as dynamic).loadSavedList();
    } catch (_) {}
    try {
      (homeProvider as dynamic).getSavedList();
    } catch (_) {}
    try {
      (homeProvider as dynamic).getList();
    } catch (_) {}

    if (homeProvider.retrieveList().isNotEmpty) {
      setState(() {});
    }
  }

  String _subKey(SubCategory sub) {
    final String catId = (sub.catId ?? '').toString().trim();
    final String subId = (sub.id ?? '').toString().trim();
    return '$catId::$subId';
  }

  bool _truthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final String s = value.toString().trim().toLowerCase();
    return s == '1' ||
        s == 'true' ||
        s == 'yes' ||
        s == 'y' ||
        s == 'selected' ||
        s == 'subscribed' ||
        s == 'subscribe';
  }

  bool _isMarkedSelectedFromApi(SubCategory sub) {
    final dynamic d = sub;

    try {
      if (_truthy(d.isSubscribe)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.isSubscribed)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.isSubScribe)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.isSelected)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.selected)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.isUserSelected)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.isFavourite)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.isFavorite)) return true;
    } catch (_) {}
    try {
      if (_truthy(d.isFav)) return true;
    } catch (_) {}

    return false;
  }

  void _hydrateSelectionsFromLoadedSubs(List<SubCategory> subs) {
    if (!mounted || subs.isEmpty) return;

    final HomeProvider homeProvider = HomeProvider.of(context, listen: false);
    bool changed = false;

    for (final SubCategory sub in subs) {
      final String key = _subKey(sub);
      if (key == '::' || _hydratedSubKeys.contains(key)) continue;

      _hydratedSubKeys.add(key);

      if (!_isMarkedSelectedFromApi(sub)) continue;
      if (homeProvider.isSubCategorySelected(subCategory: sub)) continue;

      homeProvider.toggleSelection(subCategory: sub);
      changed = true;
    }

    if (!changed) return;

    homeProvider.saveList();
    if (mounted) setState(() {});
  }

  bool _isLoggedIn() {
    final String userId = (_psValueHolder?.loginUserId ?? '').trim();
    return userId.isNotEmpty && userId != 'nologinuser';
  }

  Future<bool> _saveSelectedInterestsOrShowError() async {
    final HomeProvider homeProvider = HomeProvider.of(context, listen: false);

    if (homeProvider.retrieveList().isEmpty) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'choose_subcategory_first'),
          );
        },
      );
      return false;
    }

    homeProvider.saveList();
    await PsSharedPreferences.instance.replaceHasFavCategories(true);

    // Save to server only when the user is already logged in.
    await _autoSaveSubscriptionsIfLoggedIn(force: true);

    return true;
  }

  Future<void> _onStartPressed(BuildContext context) async {
    final bool saved = await _saveSelectedInterestsOrShowError();
    if (!saved || !mounted) return;

    // When opened from Home to edit interests, return to the same Home page
    // instead of replacing the whole navigation stack.
    if (widget.home) {
      Navigator.pop<bool>(context, true);
      widget.onTap?.call();
      return;
    }

    Navigator.pushReplacementNamed(context, RoutePaths.home);
    widget.onTap?.call();
  }

  Future<void> _onLoginPressed(BuildContext context) async {
    final bool saved = await _saveSelectedInterestsOrShowError();
    if (!saved || !mounted) return;

    if (widget.onLoginTap != null) {
      widget.onLoginTap!.call();
      return;
    }

    Navigator.pushReplacementNamed(context, RoutePaths.login_container);
  }

  String _heroAssetForCategory(Category cat) {
    final String raw = (cat.catName ?? '').trim();
    final String key = mapCategoryNameToKey(raw);
    return _mainCategoryHeroAssetsByKey[key] ??
        _mainCategoryHeroAssetsByKey['other']!;
  }

  int _pageCountFor(List<Category> cats) {
    if (cats.isEmpty) return 0;
    return (cats.length / 3).ceil();
  }

  List<Category> _catsForPage(List<Category> cats, int page) {
    final int start = page * 3;
    final int end = (start + 3) > cats.length ? cats.length : (start + 3);
    if (start >= cats.length) return <Category>[];
    return cats.sublist(start, end);
  }

  void _scheduleAutoSave({String? touchedCatId}) {
    final String safeTouchedCatId = (touchedCatId ?? '').trim();
    if (safeTouchedCatId.isNotEmpty) {
      _touchedCatIds.add(safeTouchedCatId);
    }

    // Keep local selection updated immediately so reopening CategoryListView
    // shows the already selected interests.
    HomeProvider.of(context, listen: false).saveList();

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 700), () {
      _autoSaveSubscriptionsIfLoggedIn();
    });
  }

  Future<void> _autoSaveSubscriptionsIfLoggedIn({bool force = false}) async {
    if (!mounted) return;
    final PsValueHolder? holder = _psValueHolder;
    if (holder == null) return;

    final String userId = (holder.loginUserId ?? '').trim();
    if (userId.isEmpty) return;

    final SubCategoryRepository subRepo =
    Provider.of<SubCategoryRepository>(context, listen: false);

    final List<dynamic> selected =
    HomeProvider.of(context, listen: false).retrieveList();

    final Map<String, List<String>> selectedByCat = <String, List<String>>{};
    for (final dynamic x in selected) {
      if (x is SubCategory) {
        final String cId = (x.catId ?? '').toString();
        final String sId = (x.id ?? '').toString();
        if (cId.isEmpty || sId.isEmpty) continue;
        (selectedByCat[cId] ??= <String>[]).add(sId);
      }
    }

    for (final String touchedCatId in _touchedCatIds) {
      selectedByCat.putIfAbsent(touchedCatId, () => <String>[]);
    }

    if (selectedByCat.isEmpty) return;

    final Map<String, List<String>> savePayload = force
        ? selectedByCat
        : Map<String, List<String>>.fromEntries(
      selectedByCat.entries.where(
            (MapEntry<String, List<String>> e) => _touchedCatIds.contains(e.key),
      ),
    );

    if (savePayload.isEmpty) return;

    for (final MapEntry<String, List<String>> e in savePayload.entries) {
      final String catId = e.key;
      final List<String> subIds = e.value;

      final List<String?> subIdsWithMB =
      subIds.map((String s) => '${s}_MB').toList();

      final SubscribeParameterHolder holderReq = SubscribeParameterHolder(
        userId: userId,
        catId: catId,
        selectedsubCatId: subIdsWithMB,
      );

      try {
        final SubCategoryProvider p =
        SubCategoryProvider(repo: subRepo, psValueHolder: holder);
        final PsResource<ApiStatus> res =
        await p.postSubCategorySubscribe(holderReq.toMap());

        if (!mounted) return;
        if (res.status != PsStatus.SUCCESS) {
          // silent fail
        }
      } catch (_) {
        // silent fail
      }
    }

    _touchedCatIds.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('تم تحديث تفضيلاتك'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  bool _isSubSelected(SubCategory sub) {
    return HomeProvider.of(context, listen: false)
        .isSubCategorySelected(subCategory: sub);
  }

  void _toggleSubSelection(SubCategory sub) {
    HomeProvider.of(context, listen: false).toggleSelection(subCategory: sub);
    setState(() {});
    _scheduleAutoSave(touchedCatId: (sub.catId ?? '').toString());
  }

  // ✅ Select All helpers (per main category card)
  bool _areAllSubsSelected(List<SubCategory> subs) {
    if (subs.isEmpty) return false;
    for (final SubCategory s in subs) {
      if (!_isSubSelected(s)) return false;
    }
    return true;
  }

  void _toggleSelectAll(List<SubCategory> subs) {
    if (subs.isEmpty) return;

    final bool allSelected = _areAllSubsSelected(subs);

    // if all selected => deselect all; else select all
    for (final SubCategory s in subs) {
      final bool selected = _isSubSelected(s);
      if (!allSelected && !selected) {
        HomeProvider.of(context, listen: false).toggleSelection(subCategory: s);
      } else if (allSelected && selected) {
        HomeProvider.of(context, listen: false).toggleSelection(subCategory: s);
      }
    }

    setState(() {});
    _scheduleAutoSave(
      touchedCatId: subs.isEmpty ? null : (subs.first.catId ?? '').toString(),
    );
  }

  // ✅ allow 2 chips per row naturally (based on full card width)
  double _chipMaxWidthFor(double availableW) {
    final double w = (availableW - 10) / 2;
    return w.clamp(80.0, 138.0);
  }

  Widget _buildChip(SubCategory sub, {required double maxWidth}) {
    final bool selected = _isSubSelected(sub);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => _toggleSubSelection(sub),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsetsDirectional.only(
              start: 7,
              end: 9,
              top: 6,
              bottom: 6,
            ),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: <double>[0.0, 0.45, 1.0],
                colors: <Color>[
                  Color(0xFF0C2345),
                  Color(0xFF102E5C),
                  Color(0xFF0FA3A6),
                ],
              )
                  : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.45)
                    : const Color(0xFF0FA3A6).withValues(alpha: 0.35),
                width: selected ? 1.1 : 1.0,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: selected ? 0.16 : 0.10),
                  blurRadius: selected ? 10 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.85),
                    border: Border.all(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF0FA3A6).withValues(alpha: 0.75),
                      width: 1.4,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: Color(0xFF0FA3A6),
                  )
                      : null,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    (sub.name ?? '').trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.8,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? Colors.white
                          : Colors.black.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ✅ 2nd mirrored
  bool _isMirroredCardOnPage(int indexInPage) {
    return indexInPage == 1;
  }

  Widget _buildHeroCard({
    required Category cat,
    required double height,
    required bool mirrorLayout,
  }) {
    final String catId = (cat.catId ?? '').toString();
    final String title = (cat.catName ?? '').trim();
    final String asset = _heroAssetForCategory(cat);

    final SubCategoryRepository subRepo =
    Provider.of<SubCategoryRepository>(context, listen: false);

    return ChangeNotifierProvider<SubCategoryProvider>(
      key: ValueKey<String>('subprov_$catId'),
      lazy: false,
      create: (BuildContext ctx) {
        final SubCategoryProvider p =
        SubCategoryProvider(repo: subRepo, psValueHolder: _psValueHolder);
        p.subCategoryParameterHolder.catId = catId;
        p.categoryId = catId;

        p.loadAllSubCategoryList(
          p.subCategoryParameterHolder.toMap(),
          Utils.checkUserLoginId(_psValueHolder!),
        );
        return p;
      },
      child: Consumer<SubCategoryProvider>(
        builder: (BuildContext ctx, SubCategoryProvider p, Widget? _) {
          final bool loading = p.subCategoryList.status == PsStatus.BLOCK_LOADING ||
              p.subCategoryList.status == PsStatus.PROGRESS_LOADING ||
              p.subCategoryList.status == PsStatus.LOADING;

          final bool success = p.subCategoryList.status == PsStatus.SUCCESS;
          final List<SubCategory> chips =
          (p.subCategoryList.data ?? <SubCategory>[]);
          final String? errMsg = p.subCategoryList.message;

          if (p.subCategoryList.status == PsStatus.SUCCESS && chips.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _hydrateSelectionsFromLoadedSubs(chips);
            });
          }

          // ✅ show more nicely
          final bool smallScreen = MediaQuery.of(context).size.width < 380;
          final int maxShow = smallScreen ? 8 : 10;
          final bool hasMore = chips.length > maxShow;
          final List<SubCategory> show =
          hasMore ? chips.take(maxShow).toList() : chips;

          final bool allSelected = (!loading && chips.isNotEmpty)
              ? _areAllSubsSelected(chips)
              : false;

          // ✅ alignment rules
          final AlignmentDirectional chipsAlign = mirrorLayout
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart;
          final WrapAlignment wrapAlign =
          mirrorLayout ? WrapAlignment.end : WrapAlignment.start;

          return Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withValues(alpha: 0.55),
              border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: Image.asset(asset, fit: BoxFit.cover)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: <Color>[
                          const Color(0xFF0B132B).withValues(alpha: 0.55),
                          const Color(0xFF0B132B).withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                PositionedDirectional(
                  start: 10,
                  end: 10,
                  top: 10,
                  bottom: 10,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints c) {
                      final double availableW = c.maxWidth;
                      final double chipMaxW = _chipMaxWidthFor(availableW);

                      Widget chipsWidget() {
                        if (loading) {
                          return Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.25),
                            highlightColor: Colors.white.withValues(alpha: 0.75),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: wrapAlign,
                              children: const <Widget>[
                                _ChipSkeleton(),
                                _ChipSkeleton(),
                                _ChipSkeleton(),
                                _ChipSkeleton(),
                              ],
                            ),
                          );
                        }

                        if (!success && (errMsg ?? '').isNotEmpty) {
                          return Text(
                            'تعذر تحميل التصنيفات الفرعية',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontWeight: FontWeight.w800,
                            ),
                          );
                        }

                        if (chips.isEmpty) {
                          return Text(
                            'لا توجد فئات فرعية',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontWeight: FontWeight.w800,
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: wrapAlign,
                          children: <Widget>[
                            ...show.map((SubCategory s) {
                              return _buildChip(s, maxWidth: chipMaxW);
                            }),
                            if (hasMore)
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text('سنضيف شاشة "المزيد" هنا'),
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '+ المزيد',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }

                      final TextAlign titleAlign =
                      mirrorLayout ? TextAlign.left : TextAlign.right;

                      // ✅ Select All button style
                      Widget selectAllButton() {
                        if (loading || chips.isEmpty) return const SizedBox.shrink();

                        final String label =
                        allSelected ? 'إلغاء الكل' : 'اختيار الكل';

                        return InkWell(
                          onTap: () => _toggleSelectAll(chips),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: <double>[0.0, 0.45, 1.0],
                                colors: <Color>[
                                  Color(0xFF0C2345),
                                  Color(0xFF102E5C),
                                  Color(0xFF0FA3A6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              textDirection: TextDirection.rtl,
                              children: <Widget>[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.90),
                                      width: 1.3,
                                    ),
                                  ),
                                  child: allSelected
                                      ? const Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Color(0xFF0FA3A6),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // ✅ Title row + Select All
                          Row(
                            children: <Widget>[
                              if (mirrorLayout) ...<Widget>[
                                selectAllButton(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    title,
                                    textDirection: TextDirection.rtl,
                                    textAlign: titleAlign,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      shadows: <Shadow>[
                                        Shadow(
                                          color:
                                          Colors.black.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...<Widget>[
                                Expanded(
                                  child: Text(
                                    title,
                                    textDirection: TextDirection.rtl,
                                    textAlign: titleAlign,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      shadows: <Shadow>[
                                        Shadow(
                                          color:
                                          Colors.black.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                selectAllButton(),
                              ],
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ✅ CHIPS under title, aligned to edge
                          Expanded(
                            child: Align(
                              alignment: chipsAlign,
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: chipsWidget(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageLayout(List<Category> pageCats) {
    return Padding(
      // ✅ gives breathing space between pages for Peek
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
        itemCount: pageCats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int i) {
          final Category c = pageCats[i];
          final bool mirror = _isMirroredCardOnPage(i);
          return _buildHeroCard(
            cat: c,
            height: 170,
            mirrorLayout: mirror,
          );
        },
      ),
    );
  }

  // ✅ Top-left step indicator: "1/4" + progress bar
  Widget _buildTopStepper({required int pageCount}) {
    if (pageCount <= 1) return const SizedBox.shrink();

    final int current = (_currentPage + 1).clamp(1, pageCount);

    final bool canGoBack = _currentPage > 0;
    final bool canGoNext = _currentPage < pageCount - 1;

    Widget arrowButton({
      required IconData icon,
      required bool enabled,
      required VoidCallback? onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: <double>[0.0, 0.45, 1.0],
                colors: <Color>[
                  Color(0xFF0C2345),
                  Color(0xFF102E5C),
                  Color(0xFF0FA3A6),
                ],
              )
                  : null,
              color: enabled ? null : Colors.white.withValues(alpha: 0.70),
              border: Border.all(
                color: enabled
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1.0,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: enabled ? 0.14 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: enabled
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.25),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: AlignmentDirectional.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            arrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: canGoBack,
              onTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),

            const SizedBox(width: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                '$current / $pageCount',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.78),
                ),
              ),
            ),

            const SizedBox(width: 14),

            arrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: canGoNext,
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBottomActions(BuildContext context) {
    final bool loggedIn = _isLoggedIn();

    // In Home edit mode, keep the old single save button behavior.
    if (widget.home || loggedIn) {
      return TaapdeelButton(
        label: widget.home ? 'حفظ تعديل اهتماماتك' : 'إكتشف منتجات تناسبك',
        onPressed: () => _onStartPressed(context),
        isPrimary: true,
        isExpanded: true,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: TaapdeelButton(
              label: 'تسجيل الدخول',
              onPressed: () => _onLoginPressed(context),
              isPrimary: false,
              isExpanded: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TaapdeelButton(
              label: 'إكتشف منتجات تناسبك',
              onPressed: () => _onStartPressed(context),
              isPrimary: true,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CategoryRepository categoryRepo =
    Provider.of<CategoryRepository>(context, listen: false);

    _psValueHolder = Provider.of<PsValueHolder>(context, listen: false);

    return WillPopScope(
      onWillPop: _requestPop,
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<CategoryProvider>(
            lazy: false,
            create: (BuildContext ctx) {
              final CategoryProvider provider = CategoryProvider(
                repo: categoryRepo,
                psValueHolder: _psValueHolder,
              );

              provider.loadCategoryList(
                provider.categoryParameterHolder.toMap(),
                Utils.checkUserLoginId(provider.psValueHolder!),
              );

              return provider;
            },
          ),
        ],
        child: TaapdeelScaffold(
          safeTop: true,
          safeBottom: true,
          padding: EdgeInsets.zero,
          bottom: _buildBottomActions(context),
          body: Consumer<CategoryProvider>(
            builder: (BuildContext ctx, CategoryProvider categoryProvider, Widget? _) {
              final List<Category> categories = List<Category>.from(
                categoryProvider.categoryList.data ?? <Category>[],
              );

              if (categories.isNotEmpty && categories.first.catId == '0') {
                categories.removeAt(0);
              }

              final String? gender = _readUserGender(_psValueHolder);
              final String? ageRange = _readUserAgeRange(_psValueHolder);
              if (gender != null && ageRange != null) {
                sortCategoriesByProfile(
                  categories: categories,
                  gender: gender,
                  ageRange: ageRange,
                );
              }

              final ThemeData theme = Theme.of(context);
              final ColorScheme colorScheme = theme.colorScheme;

              final int pageCount = _pageCountFor(categories);

              return Stack(
                children: <Widget>[
                  Container(
                    color: _bg,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            PsDimens.space16,
                            PsDimens.space12,
                            PsDimens.space16,
                            PsDimens.space2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const SizedBox(height: 10),
                              TaapdeelCard(
                                title: 'اختر اهتماماتك',
                                body: Text(
                                  'اختر اهتماماتك لعرض المنتجات المناسبة لك',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),

                              // ✅ new top stepper (left)
                            ],
                          ),
                        ),

                        Expanded(
                          child: (categories.isEmpty)
                              ? const SizedBox()
                              : PageView.builder(
                            controller: _pageController,
                            itemCount: pageCount,
                            padEnds: true,
                            onPageChanged: (int p) {
                              setState(() => _currentPage = p);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final List<Category> pageCats =
                              _catsForPage(categories, index);
                              return _buildPageLayout(pageCats);
                            },
                          ),
                        ),

                        // ✅ removed: _buildPagerHint + dots
                        const SizedBox(height: 8),
                        _buildTopStepper(pageCount: pageCount),

                      ],
                    ),
                  ),

                  PSProgressIndicator(
                    categoryProvider.categoryList.status,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChipSkeleton extends StatelessWidget {
  const _ChipSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
