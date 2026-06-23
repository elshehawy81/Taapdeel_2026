import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/category/category_provider.dart';
import 'package:taapdeel/provider/subcategory/sub_category_provider.dart';
import 'package:taapdeel/repository/category_repository.dart';
import 'package:taapdeel/repository/sub_category_repository.dart';
import 'package:taapdeel/ui/Foryou/home_provider.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/subscribe_parameter_holder.dart';
import 'package:taapdeel/viewobject/sub_category.dart';

import 'category_personalization.dart';

class DefaultInterestsBootstrapper {
  const DefaultInterestsBootstrapper._();

  static const int defaultMainCategoryCount = 2;

  // ─────────────────────────────────────────────────────────────────────
  // Status helpers
  // ─────────────────────────────────────────────────────────────────────

  static String _safeStatus(dynamic status) => status?.toString() ?? '';

  static bool _isLoadingStatus(dynamic status) {
    final String s = _safeStatus(status).toLowerCase();
    return s.contains('loading') || s.contains('progress');
  }

  /// ✅ الداتا جاهزة لو:
  ///   - count > 0، أو
  ///   - status يحتوي على 'success'، أو
  ///   - status مش null ومش loading (error, empty, idle, etc.)
  static bool _isReady(
      dynamic Function() getStatus,
      int Function() getCount,
      ) {
    if (getCount() > 0) return true;

    final String s = _safeStatus(getStatus()).toLowerCase();
    if (s.contains('success')) return true;
    if (s.isNotEmpty && !_isLoadingStatus(s)) return true;

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Wait helpers  (Completer + listener + polling fallback + timeout)
  // ─────────────────────────────────────────────────────────────────────

  static Future<void> _waitForCategoryProvider(CategoryProvider provider) =>
      _waitForProviderResource(
        getStatus: () => provider.categoryList.status,
        getCount: () => provider.categoryList.data?.length ?? 0,
        addListener: provider.addListener,
        removeListener: provider.removeListener,
      );

  static Future<void> _waitForSubCategoryProvider(
      SubCategoryProvider provider,
      ) =>
      _waitForProviderResource(
        getStatus: () => provider.subCategoryList.status,
        getCount: () => provider.subCategoryList.data?.length ?? 0,
        addListener: provider.addListener,
        removeListener: provider.removeListener,
      );

  static Future<void> _waitForProviderResource({
    required dynamic Function() getStatus,
    required int Function() getCount,
    required void Function(VoidCallback listener) addListener,
    required void Function(VoidCallback listener) removeListener,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    // ✅ 1. لو الداتا جاهزة فعلاً من أول لحظة، ارجع فوراً (بدون listener)
    if (_isReady(getStatus, getCount)) return;

    final Completer<void> completer = Completer<void>();

    late VoidCallback listener;
    listener = () {
      if (!completer.isCompleted && _isReady(getStatus, getCount)) {
        completer.complete();
      }
    };

    addListener(listener);

    // ✅ 2. Polling كل 200ms كـ safety net
    //    يحمي من حالة "provider notified قبل ما نضيف الـ listener"
    final Timer pollTimer = Timer.periodic(
      const Duration(milliseconds: 200),
          (_) => listener(),
    );

    // ✅ 3. Timeout كحد أقصى
    final Timer timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;

    pollTimer.cancel();
    timeoutTimer.cancel();
    removeListener(listener);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Main entry point
  // ─────────────────────────────────────────────────────────────────────

  static Future<void> ensureDefaultInterests({
    required BuildContext context,
    required PsValueHolder valueHolder,
    bool force = false,
    bool syncToServerIfLoggedIn = true,
    String? genderOverride,
    String? ageRangeOverride,
    String source = 'unknown',
  }) async {
    if (!context.mounted) return;

    final HomeProvider homeProvider = HomeProvider.of(context, listen: false);
    final int localCount = homeProvider.retrieveList().length;

    // ✅ لو عنده selections فعلية، احفظهم وسنكهم فقط
    if (!force && localCount > 0) {
      homeProvider.saveList();
      await PsSharedPreferences.instance.replaceHasFavCategories(true);

      if (syncToServerIfLoggedIn) {
        await syncLocalInterestsToServerIfLoggedIn(
          context: context,
          valueHolder: valueHolder,
          source: '$source/existing-local',
        );
      }
      return;
    }

    // ✅ اقرأ gender/age مع الـ overrides
    final String gender =
    (genderOverride ?? _readUserGender(valueHolder)).trim();
    final String ageRange =
    (ageRangeOverride ?? _readUserAgeRange(valueHolder)).trim();

    if (gender.isEmpty || ageRange.isEmpty) {
      debugPrint(
        'DefaultInterestsBootstrapper [$source] skipped: '
            'gender="$gender" ageRange="$ageRange"',
      );
      return;
    }

    final CategoryRepository categoryRepo =
    Provider.of<CategoryRepository>(context, listen: false);
    final SubCategoryRepository subRepo =
    Provider.of<SubCategoryRepository>(context, listen: false);

    final String? loginUserId = Utils.checkUserLoginId(valueHolder)?.trim();

    // ── Load categories ───────────────────────────────────────────────
    final CategoryProvider categoryProvider = CategoryProvider(
      repo: categoryRepo,
      psValueHolder: valueHolder,
    );

    await categoryProvider.loadCategoryList(
      categoryProvider.categoryParameterHolder.toMap(),
      loginUserId,
    );
    await _waitForCategoryProvider(categoryProvider);

    if (!context.mounted) {
      categoryProvider.dispose();
      return;
    }

    // ✅ انسخ الداتا قبل الـ dispose
    final List<Category> categories = List<Category>.from(
      categoryProvider.categoryList.data ?? <Category>[],
    );
    categoryProvider.dispose();

    categories.removeWhere((Category c) => (c.catId ?? '').toString() == '0');

    if (categories.isEmpty) {
      debugPrint(
        'DefaultInterestsBootstrapper [$source]: no categories returned.',
      );
      await PsSharedPreferences.instance.replaceHasFavCategories(false);
      return;
    }

    // ✅ رتّب التصنيفات حسب gender + ageRange
    sortCategoriesByProfile(
      categories: categories,
      gender: gender,
      ageRange: ageRange,
    );

    final List<Category> selectedMainCategories =
    categories.take(defaultMainCategoryCount).toList();

    bool changed = false;

    // ── Load subcategories لكل تصنيف ─────────────────────────────────
    for (final Category category in selectedMainCategories) {
      final String catId = (category.catId ?? '').toString().trim();
      if (catId.isEmpty) continue;

      final SubCategoryProvider subProvider = SubCategoryProvider(
        repo: subRepo,
        psValueHolder: valueHolder,
      );

      subProvider.subCategoryParameterHolder.catId = catId;
      subProvider.categoryId = catId;

      await subProvider.loadAllSubCategoryList(
        subProvider.subCategoryParameterHolder.toMap(),
        loginUserId,
      );
      await _waitForSubCategoryProvider(subProvider);

      // ✅ انسخ الداتا قبل الـ dispose
      final List<SubCategory> subCategories = List<SubCategory>.from(
        subProvider.subCategoryList.data ?? <SubCategory>[],
      );
      subProvider.dispose();

      for (final SubCategory subCategory in subCategories) {
        final String subId = (subCategory.id ?? '').toString().trim();
        final String subCatId = (subCategory.catId ?? '').toString().trim();
        if (subId.isEmpty || subCatId.isEmpty) continue;

        if (!homeProvider.isSubCategorySelected(subCategory: subCategory)) {
          homeProvider.toggleSelection(subCategory: subCategory);
          changed = true;
        }
      }
    }

    final int finalLocalCount = homeProvider.retrieveList().length;

    if (changed || finalLocalCount > 0) {
      homeProvider.saveList();
      await PsSharedPreferences.instance.replaceHasFavCategories(true);
      debugPrint(
        'DefaultInterestsBootstrapper [$source] saved $finalLocalCount '
            'default interests locally.',
      );
    } else {
      await PsSharedPreferences.instance.replaceHasFavCategories(false);
      debugPrint(
        'DefaultInterestsBootstrapper [$source]: no subcategories found.',
      );
    }

    if (syncToServerIfLoggedIn) {
      await syncLocalInterestsToServerIfLoggedIn(
        context: context,
        valueHolder: valueHolder,
        source: '$source/after-generation',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Sync to server
  // ─────────────────────────────────────────────────────────────────────

  static Future<void> syncLocalInterestsToServerIfLoggedIn({
    required BuildContext context,
    required PsValueHolder valueHolder,
    String source = 'unknown',
  }) async {
    if (!context.mounted) return;

    final String? userId = Utils.checkUserLoginId(valueHolder)?.trim();
    if (userId == null || userId.isEmpty || userId == 'nologinuser') return;

    final HomeProvider homeProvider = HomeProvider.of(context, listen: false);
    final List<dynamic> selectedList = homeProvider.retrieveList();
    if (selectedList.isEmpty) return;

    final SubCategoryRepository subRepo =
    Provider.of<SubCategoryRepository>(context, listen: false);

    final Map<String, List<String>> selectedByCategory =
    <String, List<String>>{};

    for (final dynamic item in selectedList) {
      if (item is! SubCategory) continue;

      final String catId = (item.catId ?? '').toString().trim();
      final String subId = (item.id ?? '').toString().trim();
      if (catId.isEmpty || subId.isEmpty) continue;

      selectedByCategory.putIfAbsent(catId, () => <String>[]).add('${subId}_MB');
    }

    if (selectedByCategory.isEmpty) return;

    final SubCategoryProvider tempProvider = SubCategoryProvider(
      repo: subRepo,
      psValueHolder: valueHolder,
    );

    for (final MapEntry<String, List<String>> entry
    in selectedByCategory.entries) {
      final SubscribeParameterHolder holder = SubscribeParameterHolder(
        userId: userId,
        catId: entry.key,
        selectedsubCatId: entry.value,
      );

      try {
        await tempProvider.postSubCategorySubscribe(holder.toMap());
      } catch (e) {
        debugPrint(
          'DefaultInterestsBootstrapper [$source] sync error '
              'for cat ${entry.key}: $e',
        );
      }
    }

    tempProvider.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Readers
  // ─────────────────────────────────────────────────────────────────────

  static String _readUserGender(PsValueHolder valueHolder) {
    try {
      final dynamic v = (valueHolder as dynamic).userGender;
      if (v is String) return v.trim();
    } catch (_) {}
    return '';
  }

  static String _readUserAgeRange(PsValueHolder valueHolder) {
    try {
      final dynamic v = (valueHolder as dynamic).userAgeRange;
      if (v is String) return v.trim();
    } catch (_) {}
    return '';
  }
}
